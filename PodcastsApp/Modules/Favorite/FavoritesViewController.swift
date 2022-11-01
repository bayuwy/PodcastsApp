//
//  FavoritesViewController.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import UIKit

class FavoritesViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let inset: CGFloat = 20
    private let spacing: CGFloat = 12
    
    let viewModel = FavoritesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadPodcasts), name: NSNotification.Name.favorites, object: nil)
        
        loadPodcasts()
    }
    
    func setup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        collectionViewLayout.minimumLineSpacing = spacing
        collectionViewLayout.minimumInteritemSpacing = spacing
        collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = collectionViewLayout
    }
    
    @objc func loadPodcasts() {
        viewModel.loadPodcasts { (_) in
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPodcasts
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCellId", for: indexPath) as! FavoriteViewCell
        
        let index = indexPath.row
        cell.nameLabel.text = viewModel.podcastTrackName(at: index)
        cell.artistLabel.text = viewModel.podcastArtistName(at: index)
        cell.thumbImageView.kf.setImage(with: URL(string: viewModel.podcastImagUrl(at: index))) { (result) in
            switch result {
            case.success:
                cell.thumbImageView.contentMode = .scaleAspectFill
            case .failure:
                cell.thumbImageView.contentMode = .center
                cell.thumbImageView.image = UIImage(systemName: "photo")
            }
        }
        
        let width = floor((UIScreen.main.bounds.width - (inset * 2) - spacing) / 2)
        cell.widthConstraint.constant = width
        cell.setNeedsLayout()
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        showEpisodesViewController(podcast: viewModel.podcast(at: indexPath.item))
    }
}
