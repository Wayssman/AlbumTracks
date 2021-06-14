//
//  Track.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import Foundation

struct TrackResponse: Codable {
  let data: [TrackData]
  
  enum CodingKeys: String, CodingKey {
    case data = "data"
  }
}

struct TrackData: Codable {
  let id, name, url: String
  let duration, trackNumber: Int
  
  enum CodingKeys: String, CodingKey {
    case id, name, url, duration
    case trackNumber = "track_number"
  }
}
