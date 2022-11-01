//
//  PlayerViewController.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 01/11/22.
//

import UIKit
import Kingfisher

class PlayerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    var viewModel: PlayerViewModel!
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerProviderStateChange(_:)), name: .PlayerProviderStateDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.isPlaying {
            startTimer()
        }
    }
    
    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self, name: .PlayerProviderStateDidChange, object: nil)
    }
    
    func setup() {
        imageView.kf.setImage(with: URL(string: viewModel.episodeImageUrl)) { (result) in
            switch result {
            case.success:
                self.imageView.contentMode = .scaleAspectFill
            case .failure:
                self.imageView.contentMode = .center
                self.imageView.image = UIImage(systemName: "photo")
            }
        }
        titleLabel.text = viewModel.episodeTitle
        authorLabel.text = viewModel.episodeAuthor
        
        updateTimeInfo()
        updatePlayInfo()
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] (_) in
            self?.updateTimeInfo()
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func updateTimeInfo() {
        currentTimeLabel.text = viewModel.currentTime
        durationLabel.text = viewModel.duration
        slider.value = viewModel.currentProgress
    }
    
    func updatePlayInfo() {
        if viewModel.isPlaying {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            enlargeImageView()
        }
        else {
            playButton.setImage(UIImage(named: "play"), for: .normal)
            shrinkImageView()
        }
    }
    
    func enlargeImageView() {
        imageViewTrailingConstraint.constant = 20
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    func shrinkImageView() {
        imageViewTrailingConstraint.constant = 72
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        viewModel.goToProgress(slider.value)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        viewModel.play()
        updatePlayInfo()
        startTimer()
    }
    
    @IBAction func rewindButtonTapped(_ sender: Any) {
        viewModel.rewind()
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        viewModel.forward()
    }
    
    @objc func playerProviderStateChange(_ sender: Any) {
        updatePlayInfo()
        updateTimeInfo()
    }
}

extension UIViewController {
    func presentPlayerViewController(episode: Episode) {
        let viewController = UIStoryboard(name: "Player", bundle: nil)
            .instantiateViewController(withIdentifier: "player") as! PlayerViewController
        viewController.viewModel = PlayerViewModel(episode: episode)
        
        present(viewController, animated: true)
    }
}
