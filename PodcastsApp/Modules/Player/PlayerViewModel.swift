//
//  PlayerViewModel.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 01/11/22.
//

import Foundation

class PlayerViewModel {
    private let episode: Episode
    init(episode: Episode) {
        self.episode = episode
    }
    
    var episodeImageUrl: String {
        return episode.imageUrl
    }
    
    var episodeTitle: String {
        return episode.epTitle
    }
    
    var episodeAuthor: String {
        return episode.epAuthor
    }
    
    // MARK: - Player Provider
    
    var currentProgress: Float {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl,
           playerProvider.duration != 0 {
            return playerProvider.currentTime / playerProvider.duration
        }
        return 0
    }
    
    var currentTime: String {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl {
            let time = playerProvider.currentTime
            return Double(time).durationString
        }
        return "00:00"
    }
    
    var duration: String {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl {
            let duration = playerProvider.duration
            return Double(duration).durationString
        }
        return "__:__"
    }
    
    var isPlaying: Bool {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl {
            return playerProvider.isPodcastPlaying()
        }
        return false
    }
    
    func play() {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl {
            playerProvider.podcastPlay()
        }
        else {
            playerProvider.launchPodcastPlaylist(playlist: [episode])
        }
    }
    
    func rewind(_ timeInterval: TimeInterval = 15) {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl {
            playerProvider.podcastRewind()
        }
    }
    
    func forward(_ timeInterval: TimeInterval = 15) {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl {
            playerProvider.podcastForward()
        }
    }
    
    func goToProgress(_ value: Float) {
        let playerProvider = PlayerProvider.shared
        if playerProvider.currentStreamUrl == episode.streamUrl {
            let time = playerProvider.duration * value
            playerProvider.podcastGoTo(time: time)
        }
    }
}
