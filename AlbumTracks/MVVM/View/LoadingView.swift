//
//  LoadingView.swift
//  AlbumTracks
//
//  Created by Желанов Александр Валентинович on 03.07.2021.
//

import UIKit

final class LoadingView: UIView {
  // MARK: - Private Properties
  let loadingLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 1
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 18)
    label.text = "Loading"
    return label
  }()
  
  let activity: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.startAnimating()
    return view
  }()
  
  // MARK: - Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  convenience init(with label: String) {
    self.init()
    self.loadingLabel.text = label
  }
  // MARK: - Private Properties
  private func setupUI() {
    backgroundColor = .white
    
    layer.cornerRadius = 10
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowRadius = 5
    layer.shadowOffset = .zero
    layer.shadowOpacity = 1
    layer.masksToBounds = false
    
    addSubview(loadingLabel)
    addSubview(activity)
    NSLayoutConstraint.activate([
      loadingLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
      loadingLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
      loadingLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
      loadingLabel.heightAnchor.constraint(equalToConstant: 24),
      
      activity.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 5),
      activity.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
      activity.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
      activity.widthAnchor.constraint(equalTo: activity.heightAnchor),
    ])
  }
}
