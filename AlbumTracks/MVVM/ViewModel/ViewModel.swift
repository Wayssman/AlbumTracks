//
//  ViewModel.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {
  // MARK: - HomeError
  public enum HomeError {
    case internetError(String)
    case serverMessage(String)
  }
  
  // MARK: - Public Properties
  public let albums: PublishSubject<[AlbumData]> = PublishSubject()
  public let tracks: PublishSubject<[TrackData]> = PublishSubject()
  
  // MARK: - Private Properties
  private let networkService = NetworkService()
  private let disposeBag = DisposeBag()
  
  // MARK: - Public Methods
  public func loadData() {
    networkService.token.subscribe {
      print("new token: ", $0)
    }.disposed(by: disposeBag)
    networkService.token.onNext("wrong")
    loadAlbums(name: "Meteora")
  }
  
  public func loadAlbums(name: String) {
    networkService.getAlbums(name)
      .subscribe(onNext: { [weak self] (response, data) in
        do {
          print(data)
          let data = try JSONDecoder().decode(AlbumResponse.self, from: data)
          self?.albums.onNext(data.albums.data)
          self?.loadTracks(albumData: data.albums.data[0])
        } catch {
          print(error)
        }
      }).disposed(by: disposeBag)
  }
  
  public func loadTracks(albumData: AlbumData) {
    networkService.getTracks(albumData.id)
      .subscribe(onNext: { [weak self] (response, data) in
        do {
          let data = try JSONDecoder().decode(TrackResponse.self, from: data)
          self?.tracks.onNext(data.data)
        } catch {
          print(error)
        }
      }).disposed(by: disposeBag)
  }
}
