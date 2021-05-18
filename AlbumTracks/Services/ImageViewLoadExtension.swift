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

        self.image = nil
        // Кодируем URL
        let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let cachedImage = imageCache.object(forKey: NSString(string: imageServerUrl)) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: imageServerUrl) else { return }

        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async { [weak self] in
                    self?.image = placeHolder
                }
                return
            }
            
            if let data = data {
                if let downloadedImage = UIImage(data: data) {
                    imageCache.setObject(downloadedImage, forKey: NSString(string: imageServerUrl))
                    DispatchQueue.main.async { [weak self] in
                        self?.image = downloadedImage
                    }
                }
            }
        }).resume()
    }
}


