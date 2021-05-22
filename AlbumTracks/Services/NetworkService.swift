import RxSwift
import RxCocoa
import RxAlamofire

enum NetworkError: Error {
    case invalidUrl
    case forbidden
}

class NetworkService {
    
    private let disposeBag = DisposeBag()
    public let token = ReplaySubject<String>.create(bufferSize: 1)
    
    // Универсальная функция для загрузки данных с обновлением токена
    private func loadData(request: @escaping (String) throws -> URLRequest, response: @escaping (URLRequest) -> Observable<(HTTPURLResponse, Data)>) -> Observable<(HTTPURLResponse, Data)> {
        return Observable
            .deferred { [unowned self] in self.token.take(1) } // Берем последний элемент в последовательности
            .map { try request($0) } // Создаем запрос с использованием токена
            .flatMap { response($0) } // Получаем ответ на запрос и делаем каждый ответ Observable
            .map { response in // Проверяем ответ на ошибку авторизации
                guard response.0.statusCode != 403 else { throw NetworkError.forbidden }
                return response
            }.retry(when: { [unowned self] _ in // Запрашиваем новый токен
                return self.getToken()
            })
    }
    
    // Функция для поиска альбомов по названию
    public func getAlbums(_ name: String) -> Observable<(HTTPURLResponse, Data)> {
        
        return loadData(request: { (token) in
            guard let url = URL(string: "https://api.kkbox.com/v1.1/search?q=\(name)&type=album&territory=TW&offset=0&limit=50") else { throw NetworkError.invalidUrl }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
            request.httpMethod = "GET"
            
            return request
        }, response: { (request) in
            RxAlamofire.requestData(request)
        })
    }
    
    // Функция для загрузки треков из альбома
    public func getTracks(_ albumId: String) -> Observable<(HTTPURLResponse, Data)> {
        
        return loadData(request: { (token) in
            guard let url = URL(string: "https://api.kkbox.com/v1.1/albums/\(albumId)/tracks?territory=TW&offset=0&limit=100") else { throw NetworkError.invalidUrl }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
            request.httpMethod = "GET"
            
            return request
        }, response: { (request) in
            RxAlamofire.requestData(request)
        })
    }
    
    private func getToken() -> Observable<Void> {
        let url = URL(string: "https://account.kkbox.com/oauth2/token")!
        
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
            }).disposed(by: disposeBag)
        
        // Когда возвращаем, удаляем из последовательности предыдущий невалидный токен
        return token.skip(1).map { _ in}
    }
}
