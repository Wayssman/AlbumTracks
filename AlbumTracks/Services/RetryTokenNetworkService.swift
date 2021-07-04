//
//  RetryTokenNetworkService.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 22.06.2021.
//

import RxSwift
import RxCocoa
import RxAlamofire

public typealias Response = (URLRequest) -> Observable<(HTTPURLResponse, Data)>

final class NetworkService {
  private let tokenAcquisitionService = TokenAcquisitionService(inititalToken: "wrong", getToken: { token in
    let url = URL(string: "https://account.kkbox.com/oauth2/token")
    var request = URLRequest(url: url!)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    
    let parameters: [String: Any] = ["grant_type": "client_credentials",
                                     "client_id": "79543b96043901066017ade155265566",
                                     "client_secret": "7733dd391e9b512b26cb892b0309c639"]
    
    request.httpBody = parameters.map {key, value in
      return "\(key)" + "=" + "\(value)"
    }.joined(separator: "&").data(using: .utf8)
    return RxAlamofire.requestData(request)
  }, extractToken: { data in
    return try JSONDecoder().decode(Auth.self, from: data).token
  })
  
  func getTracks(_ albumId: String) -> Observable<(HTTPURLResponse, Data)> {
    return getData(response: { request in
      return RxAlamofire.requestData(request)
    }, tokenAcquisitionService: tokenAcquisitionService, request: { token in
      let url = URL(string: "https://api.kkbox.com/v1.1/albums/\(albumId)/tracks?territory=TW&offset=0&limit=100")
      var request = URLRequest(url: url!)
      request.setValue("application/json", forHTTPHeaderField: "accept")
      request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
      request.httpMethod = "GET"
      return request
    })
  }
  
  func getAlbums(album: String) -> Observable<(HTTPURLResponse, Data)> {
    return getData(response: { request in
      return RxAlamofire.requestData(request)
    }, tokenAcquisitionService: tokenAcquisitionService, request: { token in
      let url = URL(string: "https://api.kkbox.com/v1.1/search?q=\(album)&type=album&territory=TW&offset=0&limit=50")
      var request = URLRequest(url: url!)
      request.setValue("application/json", forHTTPHeaderField: "accept")
      request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
      request.httpMethod = "GET"
      return request
    })
  }
  
  private func getData<T>(response: @escaping Response, tokenAcquisitionService: TokenAcquisitionService<T>, request: @escaping (T) throws -> URLRequest) -> Observable<(HTTPURLResponse, Data)> {
    return Observable
      .deferred { tokenAcquisitionService.token.take(1) }
      .map { try request($0) }
      .flatMap { response($0) }
      .map { response in
        guard response.0.statusCode != 403 else { throw TokenAcquisitionError.unauthorised }
        return response
      }
      .retry(when: { $0.renewToken(with: tokenAcquisitionService) })
  }
}

public enum TokenAcquisitionError: Error, Equatable {
  case unauthorised
  case refusedToken(response: HTTPURLResponse, data: Data)
}

public final class TokenAcquisitionService<T> {
  private let _token = ReplaySubject<T>.create(bufferSize: 1)
  private let relay = PublishSubject<T>()
  private let lock = NSRecursiveLock()
  private let disposeBag = DisposeBag()
  
  public var token: Observable<T> {
    _token.asObservable()
  }
  
  public typealias GetToken = (T) -> Observable<(HTTPURLResponse, Data)>
  
  public init(inititalToken: T, getToken: @escaping GetToken, extractToken: @escaping (Data) throws -> T) {
    relay
      .flatMapFirst { getToken($0) }
      .map { (urlResponse) -> T in
        guard urlResponse.0.statusCode / 100 == 2 else { throw TokenAcquisitionError.refusedToken(response: urlResponse.0, data: urlResponse.1) }
        return try extractToken(urlResponse.1)
      }
      .startWith(inititalToken)
      .subscribe(_token)
      .disposed(by: disposeBag)
  }
  
  func trackErrors<O: ObservableConvertibleType>(for source: O) -> Observable<Void> where O.Element == Error {
    let lock = self.lock
    let relay = self.relay
    let error = source
      .asObservable()
      .map { error in
        guard (error as? TokenAcquisitionError) == .unauthorised else { throw error }
      }
      .flatMap { [unowned self] in self.token }
      .do(onNext: {
        lock.lock()
        relay.onNext($0)
        lock.unlock()
      })
      .filter{ _ in false }
      .map { _ in }
    
    return Observable.merge(token.skip(1).map { _ in }, error)
  }
}

extension ObservableConvertibleType where Element == Error {
  public func renewToken<T>(with service: TokenAcquisitionService<T>) -> Observable<Void> {
    return service.trackErrors(for: self)
  }
}
