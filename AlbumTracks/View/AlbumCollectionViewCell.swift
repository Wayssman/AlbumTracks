//
//  AlbumCollectionViewCell.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import UIKit

class AlbumsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var withBackView: Bool! {
        didSet {
            self.backView.backgroundColor = imageView.backgroundColor
        }
    }
    
    private lazy var backView: UIImageView = {
        let backView = UIImageView(frame: imageView.frame)
        backView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(backView)
        backView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -15).isActive = true
        backView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        backView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        backView.alpha = 0.5
        
        self.bringSubviewToFront(self.imageView)
        
        return backView
    }()
}
