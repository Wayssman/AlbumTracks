//
//  ViewController.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeVC: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var albumsVCView: UIView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var albumsTitle: UILabel!
  @IBOutlet weak var tracksTitle: UILabel!
  
  // MARK: - Private Properties
  private var albumsViewController: AlbumsCollectionViewVC!
  private var tracksViewController: TracksTableViewVC!
  
  private var homeViewModel = HomeViewModel()
  private let disposeBag = DisposeBag()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBindings()
    homeViewModel.loadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let offset = view.bounds.width
    albumsTitle.transform = CGAffineTransform(translationX: -offset, y: 0)
    tracksTitle.transform = CGAffineTransform(translationX: -offset, y: 0)
    
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
      self.albumsTitle.transform = .identity
    }, completion: nil)
    
    UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
      self.tracksTitle.transform = .identity
    }, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let albumsVC = segue.destination as? AlbumsCollectionViewVC, segue.identifier == "AlbumsSegue" {
      self.albumsViewController = albumsVC
    }
    if let tracksVC = segue.destination as? TracksTableViewVC, segue.identifier == "TracksSegue" {
      self.tracksViewController = tracksVC
    }
  }
  
  // MARK: - Private Methods
  private func setupBindings() {
    homeViewModel
      .albums
      .observe(on: MainScheduler.instance)
      .bind(to: albumsViewController.albums)
      .disposed(by: disposeBag)
    
    homeViewModel
      .tracks
      .observe(on: MainScheduler.instance)
      .bind(to: tracksViewController.tracks)
      .disposed(by: disposeBag)
    
    albumsViewController.albumsCollectionView.rx.modelSelected(AlbumData.self)
      .subscribe(onNext: { [weak self] album in
        self?.homeViewModel.loadTracks(albumData: album)
      }).disposed(by: disposeBag)
    
    searchBar.rx.text
      .orEmpty
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [weak self] text in
        self?.homeViewModel.loadAlbums(name: text)
      })
      .disposed(by: disposeBag)
  }
}

