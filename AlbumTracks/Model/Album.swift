//
//  Album.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import Foundation

struct Album: Codable {
    let id, name, albumArtWork, artist: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case albumArtWork = "album_art_work"
        case artist
    }
}

extension Album {
    init?(data: Data) {
        guard let album = try? JSONDecoder().decode(Album.self, from: data) else { return nil }
        self = album
    }
}
