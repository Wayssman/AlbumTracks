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
    
    public let albums: PublishSubject<[Album]> = PublishSubject()
    public let tracks: PublishSubject<[Track]> = PublishSubject()
    
    public func loadData() {
        let albumsModel =
            [Album(id: "First", name: "First", albumArtWork: "First", artist: "First"),
             Album(id: "Second", name: "Second", albumArtWork: "Second", artist: "Second"),
             Album(id: "Third", name: "Third", albumArtWork: "Third", artist: "Third"),
             Album(id: "Fourth", name: "Fourth", albumArtWork: "Fourth", artist: "Fourth"),
             Album(id: "Fifth", name: "Fifth", albumArtWork: "Fifth", artist: "Fifth")]
        self.albums.onNext(albumsModel)
        
        let tracksModel =
            [Track(id: "First", name: "First", trackArtWork: "First", trackAlbum: "First", artist: "First"),
             Track(id: "Second", name: "Second", trackArtWork: "Second", trackAlbum: "Second", artist: "Second"),
             Track(id: "Third", name: "Third", trackArtWork: "Third", trackAlbum: "Third", artist: "Third"),
             Track(id: "Fouth", name: "Fouth", trackArtWork: "Fouth", trackAlbum: "Fouth", artist: "Fouth"),
             Track(id: "Fifth", name: "Fifth", trackArtWork: "Fifth", trackAlbum: "Fifth", artist: "Fifth")]
        self.tracks.onNext(tracksModel)
    }
}
