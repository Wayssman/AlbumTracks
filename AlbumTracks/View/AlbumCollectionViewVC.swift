//
//  AlbumCollectionViewVC.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class AlbumsCollectionViewVC: UIViewController {

    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    public var albums = PublishSubject<[Album]>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        albumsCollectionView.register(UINib(nibName: "AlbumsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlbumsCollectionViewCell")
        
        albums.bind(to: albumsCollectionView.rx.items(cellIdentifier: "AlbumsCollectionViewCell", cellType: AlbumsCollectionViewCell.self)) { (row, album, cell) in
            cell.withBackView = true
            cell.titleLabel.text = album.name
        }.disposed(by: disposeBag)
        
        albumsCollectionView.rx.willDisplayCell
            .subscribe(onNext: { (cell, indexPath) in
                cell.alpha = 0
                cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -100, 0)
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    cell.alpha = 1
                    cell.layer.transform = CATransform3DIdentity
                }, completion: nil)
            }).disposed(by: disposeBag)
    }
    
}
