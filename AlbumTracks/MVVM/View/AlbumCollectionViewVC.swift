//
//  AlbumCollectionViewVC.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class AlbumsCollectionViewVC: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var albumsCollectionView: UICollectionView!
  
  // MARK: - Public Properties
  public var albums = PublishSubject<[AlbumData]>()
  
  // MARK: - Private Properties
  private let disposeBag = DisposeBag()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    albumsCollectionView.register(UINib(nibName: "AlbumsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlbumsCollectionViewCell")
    setupBindings()
    setupAnimation()
  }
  
  // MARK: - Private Methods
  private func setupBindings() {
    albums.bind(to: albumsCollectionView.rx.items(cellIdentifier: "AlbumsCollectionViewCell", cellType: AlbumsCollectionViewCell.self)) { (row, album, cell) in
      cell.album = album
      cell.withBackView = true
    }.disposed(by: disposeBag)
  }
  
  private func setupAnimation() {
    albumsCollectionView.rx.willDisplayCell
      .subscribe(onNext: { (cell, indexPath) in
        cell.alpha = 0
        cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -100, 0)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
          cell.alpha = 1
          cell.layer.transform = CATransform3DIdentity
        }, completion: nil)
      }).disposed(by: disposeBag)
  }
}
