//
//  ViewModel.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    
    public enum HomeError {
        case internetError(String)
        case serverMessage(String)
    }
    
    public let albums: PublishSubject<[AlbumData]> = PublishSubject()
    public let tracks: PublishSubject<[TrackData]> = PublishSubject()
    
    let networkService = NetworkService()
    
    private let disposeBag = DisposeBag()
    
    public func loadData() {
        networkService.getToken()
        networkService.token.take(1).subscribe(onNext: { token in
            self.networkService.getAlbums(token: token, name: "Meteora", completion: { [weak self] (data) in
                do {
                    let data = try JSONDecoder().decode(AlbumResponse.self, from: data)
                    self?.albums.onNext(data.albums.data)
                    print(data.albums.data[0].id)
                    self?.loadTracks(albumData: data.albums.data[0])
                } catch {
                    print(error)
                }
            })
        }).disposed(by: disposeBag)
        /*networkService.getAlbums(token: "jXa4as02TG43K83j0zs5jg==", name: "Meteora", completion: { [weak self] (data) in
            do {
                let data = try JSONDecoder().decode(AlbumResponse.self, from: data)
                self?.albums.onNext(data.albums.data)
                print(data.albums.data[0].id)
                self?.loadTracks(albumData: data.albums.data[0])
            } catch {
                print(error)
            }
        })*/
    }
    
    public func loadTracks(albumData: AlbumData) {
        networkService.token.take(1).subscribe(onNext: { token in
            self.networkService.getTracks(token: token, albumId: albumData.id, completion: { [weak self] (data) in
                do {
                    let data = try JSONDecoder().decode(TrackResponse.self, from: data)
                    self?.tracks.onNext(data.data.sorted(by: { h1, h2 in
                        return h1.trackNumber < h2.trackNumber
                    }))
                } catch {
                    print(error)
                }
            })
        }).disposed(by: disposeBag)
        
        /*networkService.getTracks(token: "jXa4as02TG43K83j0zs5jg==", albumId: albumData.id, completion: { [weak self] (data) in
            do {
                let data = try JSONDecoder().decode(TrackResponse.self, from: data)
                self?.tracks.onNext(data.data.sorted(by: { h1, h2 in
                    return h1.trackNumber < h2.trackNumber
                }))
            } catch {
                print(error)
            }
        })*/
    }
}
