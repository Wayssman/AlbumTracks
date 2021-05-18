//
//  Album.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import Foundation

struct AlbumResponse: Codable {
    let albums: Albums
}

struct Albums: Codable {
    let data: [AlbumData]
}

struct AlbumData: Codable {
    let id, name: String
    let images: [AlbumImages]
}

struct AlbumImages: Codable {
    let height, width: Int
    let url: String
}
