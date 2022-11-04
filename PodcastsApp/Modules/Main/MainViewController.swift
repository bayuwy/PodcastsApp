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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerProviderStateDidChange(_:)),
            name: .PlayerProviderStateDidChange,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerProviderNowPlayingInfoDidChange(_:)),
            name: .PlayerProviderNowPlayingInfoDidChange,
            object: nil
        )
    }
    
    @objc func playerProviderStateDidChange(_ sender: Notification) {
        playerProviderNowPlayingInfoDidChange(sender)
        
        if playerView.isHidden {
            showPlayerView()
        }
    }
    
    @objc func playerProviderNowPlayingInfoDidChange(_ sender: Notification) {
        let playerProvider = PlayerProvider.shared
        let episode = playerProvider.currentEpisode
        
        playerView.titleLabel.text = episode?.epTitle
        let image = UIImage(systemName: playerProvider.isPodcastPlaying() ? "pause.fill" : "play.fill")
        playerView.playButton.setImage(image, for: .normal)
        playerView.imageView.kf.setImage(with: URL(string: episode?.imageUrl ?? "")) { (result) in
            switch result {
            case.success:
                self.playerView.imageView.contentMode = .scaleAspectFill
            case .failure:
                self.playerView.imageView.contentMode = .center
                self.playerView.imageView.image = UIImage(systemName: "photo")
            }
        }
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
        PlayerProvider.shared.podcastPlay()
    }
    
    func playerViewRewindButtonTapped(_ view: PlayerView) {
        PlayerProvider.shared.podcastRewind()
    }
    
    func playerViewForwardButtonTapped(_ view: PlayerView) {
        PlayerProvider.shared.podcastForward()
    }
    
    func playerViewTapped(_ view: PlayerView) {
        if let episode = PlayerProvider.shared.currentEpisode {
            presentPlayerViewController(episode: episode)
        }
    }
}
