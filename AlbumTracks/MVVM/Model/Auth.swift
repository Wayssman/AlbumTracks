//
//  Auth.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 07.05.2021.
//

import Foundation

struct Auth: Codable {
  let token, expires, type: String
  
  enum CodingKeys: String, CodingKey {
    case token = "access_token"
    case expires = "expires_in"
    case type = "token_type"
  }
}
