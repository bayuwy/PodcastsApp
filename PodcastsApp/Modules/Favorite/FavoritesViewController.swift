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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
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
}

// MARK: - UICollectionViewDataSource
extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCellId", for: indexPath) as! FavoriteViewCell
        
        let width = floor((UIScreen.main.bounds.width - (inset * 2) - spacing) / 2)
        cell.widthConstraint.constant = width
        cell.setNeedsLayout()
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
