//
//  Track.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import Foundation

struct Track: Codable {
    let id, name, trackArtWork, trackAlbum: String
    let artist: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case trackArtWork = "track_art_work"
        case trackAlbum = "track_album"
        case artist
    }
}

extension Track {
    init?(data: Data) {
        guard let track = try? JSONDecoder().decode(Track.self, from: data) else { return nil }
        self = track 
    }
}
