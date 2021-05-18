//
//  ViewController.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class HomeVC: UIViewController {

    @IBOutlet weak var albumsVCView: UIView!
    
    private var albumsViewController: AlbumsCollectionViewVC!
    private var tracksViewController: TracksTableViewVC!
    
    var homeViewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        homeViewModel.loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let albumsVC = segue.destination as? AlbumsCollectionViewVC, segue.identifier == "AlbumsSegue" {
            self.albumsViewController = albumsVC
        }
        if let tracksVC = segue.destination as? TracksTableViewVC, segue.identifier == "TracksSegue" {
            self.tracksViewController = tracksVC
        }
    }
    
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
    }
}

