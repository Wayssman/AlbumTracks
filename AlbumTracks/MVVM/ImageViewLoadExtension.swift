//
//  ImageViewLoadExtension.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 07.05.2021.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
  func imageFromServerURL(_ URLString: String, placeHolder: UIImage?) {
    image = nil
    // Кодируем URL
    let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    if let cachedImage = imageCache.object(forKey: NSString(string: imageServerUrl)) {
      image = cachedImage
      return
    }
    
    guard let url = URL(string: imageServerUrl) else { return }
    
    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
      if error != nil {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.image = placeHolder
        }
        return
      }
      
      guard let data = data else { return }
      guard let downloadedImage = UIImage(data: data) else { return }
      
      imageCache.setObject(downloadedImage, forKey: NSString(string: imageServerUrl))
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        self.image = downloadedImage
      }
    }).resume()
  }
}


