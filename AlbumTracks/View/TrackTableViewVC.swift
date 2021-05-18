//
//  TrackTableViewVCTableViewController.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 04.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TracksTableViewVC: UIViewController {
    @IBOutlet weak var tracksTableView: UITableView!
    
    public var tracks = PublishSubject<[Track]>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tracks.bind(to: tracksTableView.rx.items(cellIdentifier: "TracksTableViewCell")) { (row, track, cell) in
            cell.textLabel?.text = track.name
        }.disposed(by: disposeBag)
        
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
