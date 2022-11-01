//
//  MainViewController.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import UIKit

class MainViewController: UITabBarController {
    weak var playerView: PlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPlayerView()
    }
    
    func setup() {
        let playerView = PlayerView(frame: .zero)
        view.addSubview(playerView)
        self.playerView = playerView
        playerView.delegate = self
        playerView.isHidden = true
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
        
        view.bringSubviewToFront(playerView)
    }
    
    func showPlayerView() {
        playerView.isHidden = false
        
        viewControllers?.forEach({ viewController in
            viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 72, right: 0)
        })
    }
    
    func hidePlayerView() {
        playerView.isHidden = true
        viewControllers?.forEach({ viewController in
            viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
}

// MARK: - PlayerViewDelegate
extension MainViewController: PlayerViewDelegate {
    func playerViewPlayButtonTapped(_ view: PlayerView) {
        
    }
    
    func playerViewRewindButtonTapped(_ view: PlayerView) {
        
    }
    
    func playerViewForwardButtonTapped(_ view: PlayerView) {
        
    }
    
    func playerViewTapped(_ view: PlayerView) {
        
    }
}
