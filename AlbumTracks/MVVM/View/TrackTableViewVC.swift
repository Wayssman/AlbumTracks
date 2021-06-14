//
//  TrackTableViewVCTableViewController.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class TracksTableViewVC: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var tracksTableView: UITableView!
  
  // MARK: - Public Properties
  public var tracks = PublishSubject<[TrackData]>()
  
  // MARK: - Private Properties
  private let disposeBag = DisposeBag()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBindings()
    setupAnimation()
  }
  
  // MARK: - Private Methods
  private func setupBindings() {
    tracks.bind(to: tracksTableView.rx.items(cellIdentifier: "TracksTableViewCell")) { (row, track, cell) in
      cell.textLabel?.text = "\(track.trackNumber). " + track.name
    }.disposed(by: disposeBag)
  }
  
  private func setupAnimation() {
    tracksTableView.rx.willDisplayCell
      .subscribe(onNext: { (cell, indexPath) in
        cell.alpha = 0
        cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, -250, 0, 0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
          cell.alpha = 1
          cell.layer.transform = CATransform3DIdentity
        }, completion: nil)
      }).disposed(by: disposeBag)
  }
}
