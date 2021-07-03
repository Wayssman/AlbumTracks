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
  @IBOutlet weak var tracksTitleLeading: NSLayoutConstraint!
  @IBOutlet weak var tracksTitleTrailing: NSLayoutConstraint!
  
  // MARK: - Private Properties
  private var albumsViewController: AlbumsCollectionViewVC!
  private var tracksViewController: TracksTableViewVC!
  
  private var homeViewModel = HomeViewModel()
  private let disposeBag = DisposeBag()
  
  private let loadingView: LoadingView = {
    let view = LoadingView(with: "Загрузка")
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
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
  private func setupUI() {
    view.addSubview(loadingView)
    NSLayoutConstraint.activate([
      loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadingView.heightAnchor.constraint(equalToConstant: 100),
      loadingView.widthAnchor.constraint(equalToConstant: 200),
    ])
  }
  
  private func setupBindings() {
    homeViewModel
      .loading
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isError in
        self?.loadingView.isHidden = !isError
      })
      .disposed(by: disposeBag)
    
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
        self?.homeViewModel.loading.onNext(true)
        self?.homeViewModel.loadTracks(albumData: album)
        self?.tracksTitle.text = "\(album.name)"
      }).disposed(by: disposeBag)
    
    searchBar.rx.text
      .orEmpty
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [weak self] text in
        self?.homeViewModel.loading.onNext(true)
        self?.homeViewModel.loadAlbums(name: text)
        self?.albumsTitle.text = "Albums - \(text)"
        self?.albumsViewController.albumsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
      })
      .disposed(by: disposeBag)
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tracksTitleTapped))
    self.tracksTitle.addGestureRecognizer(gestureRecognizer)
    self.tracksTitle.isUserInteractionEnabled = true
  }
  
  @objc private func tracksTitleTapped() {
    let string = tracksTitle.text ?? ""
    let font = tracksTitle.font ?? UIFont.boldSystemFont(ofSize: 20)
    
    // Вычисляем предполагаемую ширину текста на View
    let stringBoxWidth = (string as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
    
    // Сохраняем начальное положение
    let initialLeading = tracksTitleLeading.constant
    // Считаем на сколько нам нужно сдвинуть текст
    let offset = stringBoxWidth - view.bounds.width + tracksTitleTrailing.constant + 2 * tracksTitleLeading.constant
    guard offset > 0 else { return }
    
    // Рассчитываем длительность анимации в зависимости от прокручиваемого текста
    let duration = Double(offset / 40)
    
    view.layoutIfNeeded()
    UIView.animate(withDuration: duration, delay: 0, options: [.autoreverse], animations: {
      self.tracksTitleLeading.constant -= offset
      self.view.layoutIfNeeded()
    }, completion: { _ in
      self.tracksTitleLeading.constant = initialLeading
    })
  }
}

