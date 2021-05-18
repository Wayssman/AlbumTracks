import RxSwift
import RxCocoa
import RxAlamofire

class NetworkService {
    private let disposeBag = DisposeBag()
    
    public let token = ReplaySubject<String>.create(bufferSize: 1)
    
    public func getToken() {
        guard let url = URL(string: "https://account.kkbox.com/oauth2/token") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = ["grant_type": "client_credentials",
                          "client_id": "79543b96043901066017ade155265566",
                          "client_secret": "7733dd391e9b512b26cb892b0309c639"]
        request.httpBody = parameters.map {key, value in
            return "\(key)" + "=" + "\(value)"
        }.joined(separator: "&").data(using: .utf8)
        
        RxAlamofire.requestJSON(request)
            .subscribe(onNext: { (request, json) -> Void in
                if let dict = json as? [String: AnyObject] {
                    if let token = dict["access_token"] as? String {
                        self.token.onNext(token)
                    }
                }
            }, onError: { (error) -> Void in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    func getAlbums(token: String, name: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: "https://api.kkbox.com/v1.1/search?q=\(name)&type=album&territory=TW&offset=0&limit=50") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        request.httpMethod = "GET"
        
        RxAlamofire.requestData(request)
            .subscribe(onNext: { (response, data) in
                completion(data)
                if response.statusCode == 401 {
                    
                }
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    func getTracks(token: String, albumId: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: "https://api.kkbox.com/v1.1/albums/\(albumId)/tracks?territory=TW&offset=0&limit=100") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        request.httpMethod = "GET"
        
        RxAlamofire.requestData(request)
            .subscribe(onNext: { (response, data) in
                completion(data)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
}
