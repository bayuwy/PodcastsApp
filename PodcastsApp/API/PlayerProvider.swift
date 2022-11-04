//
//  PlayerProvider.swift
//  Siniar
//
//  Created by Bayu Yasaputro on 30/08/22.
//

import Foundation
import AVFoundation
import AVKit
import MediaPlayer
import FeedKit
import Kingfisher

extension Notification.Name {
    static let PlayerProviderStateDidChange: Notification.Name = Notification.Name(rawValue: "kPlayerProviderStateDidChange")
    static let PlayerProviderNowPlayingInfoDidChange: Notification.Name = Notification.Name(rawValue: "kPlayerProviderNowPlayingInfoDidChange")
}

typealias Playlist = [Episode]

class PlayerProvider: NSObject {
    
    private var playlist: Playlist?
    private var currentIndex: Int = 0
    
    var podcastPlayer: AVPlayer!
    private var playbackLikelyToKeepUpContext: Int = 0
    private var podcastNowPlayingInfo: [String: Any] = [:]
    
    private var isAVAudioSessionActive: Bool = false
    
    private var state: State = State.paused {
        didSet { stateDidChange() }
    }
    
    static var shared: PlayerProvider = PlayerProvider()
    private override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        }
        catch {
            print("Unable to set AVAudioSession Category: \(error)")
        }
        podcastPlayer = AVPlayer()
        podcastPlayer.automaticallyWaitsToMinimizeStalling = false
    }
    
    deinit {
        
    }
    
    private func loadPodcast(episode: Episode, andPlay shouldPlay: Bool = true) {
        var url: URL?
        if let fileUrlString = episode.fileUrl, let fileUrl = URL(string: fileUrlString) {
            let fileName = fileUrl.lastPathComponent
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            trueLocation.appendPathComponent(fileName)
            url = trueLocation
        }
        else {
            url = URL(string: episode.streamUrl)
        }
        
        guard let safeUrl = url else {
            return
        }
        self.podcastPlayer.replaceCurrentItem(with: AVPlayerItem(url: safeUrl))
        // Register for notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReadyToPlay(_:)),
                                               name: .AVPlayerItemNewAccessLogEntry,
                                               object: self.podcastPlayer.currentItem)
        self.podcastPlayer.addObserver(self,
                                       forKeyPath: "currentItem.playbackLikelyToKeepUp",
                                       options: .new,
                                       context: &playbackLikelyToKeepUpContext)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.podcastPlayer.currentItem)
        self.updateInfoCenter(with: episode)
        self.updateCommandCenter()
        if shouldPlay {
            self.playPodcast()
        }
    }
    
    private func updateInfoCenter(with episode: Episode) {
        guard let url = URL(string: episode.imageUrl) else { return }
        
        ImageDownloader.default.downloadImage(with: url) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let imageLoadingResult):
                let downloadedImage = imageLoadingResult.image
                let artwork = MPMediaItemArtwork(boundsSize: downloadedImage.size, requestHandler: { _ -> UIImage in
                    return downloadedImage
                })
                self.setupNowPlayingInfo(with: artwork, for: episode)
            case .failure:
                break
            }
        }
    }
    
    private func setupNowPlayingInfo(with artwork: MPMediaItemArtwork, for episode: Episode) {
        guard let safeCurrentItem = self.podcastPlayer.currentItem else {
            return
        }
        self.podcastNowPlayingInfo[MPMediaItemPropertyTitle] = episode.epTitle
        self.podcastNowPlayingInfo[MPMediaItemPropertyArtist] = episode.epAuthor
        self.podcastNowPlayingInfo[MPMediaItemPropertyAlbumTitle] = ""
        self.podcastNowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        self.podcastNowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.podcastPlayer.rate
        self.podcastNowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(safeCurrentItem.duration)
        self.podcastNowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(safeCurrentItem.currentTime())
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.podcastNowPlayingInfo
    }
    
    private func updateNowPlayingInfo() {
        guard let safeCurrentItem = self.podcastPlayer.currentItem else {
            return
        }
        self.podcastNowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.podcastPlayer.rate
        self.podcastNowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(safeCurrentItem.duration)
        self.podcastNowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.podcastPlayer.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.podcastNowPlayingInfo
        NotificationCenter.default.post(name: .PlayerProviderNowPlayingInfoDidChange, object: self)
    }
    
    private func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func stateDidChange() {
        switch state {
        case .playing, .paused:
            NotificationCenter.default.post(name: .PlayerProviderStateDidChange, object: self)
        case .loading(let isLoading):
            NotificationCenter.default.post(name: .PlayerProviderStateDidChange, object: self, userInfo: ["isLoading": isLoading])
        }
    }
    
    func launchPodcastPlaylist(playlist: Playlist, index: Int = 0) {
        self.podcastPlayer.automaticallyWaitsToMinimizeStalling = false
        self.playlist = playlist
        self.currentIndex = index
        self.setupAVAudioSession()
        guard let episodes = self.playlist else {
            return
        }
        let episodeSafe = episodes[index]
        self.loadPodcast(episode: episodeSafe)
    }
    
    func closePodcastPlayer() {
        self.stopPodcast()
        self.podcastPlayer.replaceCurrentItem(with: nil)
        self.removeAVAudioSession()
    }
}

// MARK: - State enum
extension PlayerProvider {
    enum State {
        case playing
        case paused
        case loading(Bool)
    }
}

// MARK: - Setup
extension PlayerProvider {
    private func setupAVAudioSession() {
        if !self.isAVAudioSessionActive {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.handleInterruption(_:)),
                                                       name: AVAudioSession.interruptionNotification,
                                                       object: nil)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.handleSecondaryAudio(_:)),
                                                       name: AVAudioSession.silenceSecondaryAudioHintNotification,
                                                       object: AVAudioSession.sharedInstance())
                print("AVAudioSession is Active and Category Playback is set")
                UIApplication.shared.beginReceivingRemoteControlEvents()
                self.setupCommandCenter()
                self.isAVAudioSessionActive = true
            }
            catch {
                print("Unable to activate audio session: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeAVAudioSession() {
        if self.isAVAudioSessionActive {
            do {
                try AVAudioSession.sharedInstance().setActive(false)
                print("AVAudioSession is deactivate")
                UIApplication.shared.endReceivingRemoteControlEvents()
                self.removeCommandCenter()
                self.isAVAudioSessionActive = false
            }
            catch {
                print("Unable to deactivate audio session: \(error)")
            }
        }
    }
}

// MARK: - Podcast Controls
extension PlayerProvider {
    private func playPodcast() {
        self.podcastPlayer.play()
        state = .playing
    }
    
    private func pausePodcast() {
        self.podcastPlayer.pause()
        state = .paused
    }
    
    private func stopPodcast() {
        self.podcastPlayer.seek(to: CMTime.zero)
        self.pausePodcast()
    }
}

// MARK: - Getters
extension PlayerProvider {
    func isPodcastPlaying() -> Bool {
        return self.podcastPlayer.rate != 0.0
    }
    
    func isNextPodcastAvailable() -> Bool {
        guard let episodes = self.playlist else {
            return false
        }
        return self.currentIndex < episodes.count - 1
    }
    
    var currentEpisode: Episode? {
        if let episodes = playlist, episodes.count > currentIndex {
            return episodes[currentIndex]
        }
        return nil
    }
    
    var currentStreamUrl: String? {
        if let episodes = playlist, episodes.count > currentIndex {
            return episodes[currentIndex].streamUrl
        }
        return nil
    }
}

// MARK: - Actions
extension PlayerProvider {
    var duration: Float {
        if let safeCurrentItem = podcastPlayer.currentItem {
            return Float(CMTimeGetSeconds(safeCurrentItem.asset.duration))
        }
        return 0
    }
    
    var currentTime: Float {
        if let safeCurrentItem = podcastPlayer.currentItem {
            return Float( CMTimeGetSeconds(safeCurrentItem.currentTime()))
        }
        return 0
    }
    
    func podcastForward(_ timeInterval: Float = 15) {
        let time = min(duration, currentTime + timeInterval)
        podcastGoTo(time: time)
    }
    
    func podcastRewind(_ timeInterval: Float = 15) {
        let time = max(0, currentTime - timeInterval)
        podcastGoTo(time: time)
    }
    
    func podcastGoTo(time: Float) {
        self.podcastPlayer.seek(to: CMTime(seconds: Double(time), preferredTimescale: self.podcastPlayer.currentTime().timescale)) { _ in
            self.updateNowPlayingInfo()
        }
    }
    
    private func podcastSeekTo(time: CMTime) {
        self.podcastPlayer.seek(to: time) { _ in
            self.updateNowPlayingInfo()
        }
    }
    
    func podcastPrevious() {
        let newCurrentIndex = currentIndex - 1
        
        if newCurrentIndex < 0 {
            self.podcastSeekTo(time: CMTime(seconds: 0, preferredTimescale: self.podcastPlayer.currentTime().timescale))
        }
        else {
            guard let episodes = self.playlist else {
                return
            }
            self.currentIndex = newCurrentIndex
            self.loadPodcast(episode: episodes[newCurrentIndex])
        }
    }
    
    func podcastPlay() {
        isPodcastPlaying() ? pausePodcast() : playPodcast()
    }
    
    func podcastNext() {
        let newCurrentIndex = currentIndex + 1
        guard let episodes = self.playlist,
              newCurrentIndex <= episodes.count - 1 else {
            return
        }
        self.currentIndex = newCurrentIndex
        self.loadPodcast(episode: episodes[newCurrentIndex])
    }
    
    private func pausePodcastAndRemoveAudioSession() {
        self.pausePodcast()
        if self.isAVAudioSessionActive {
            self.clearNowPlayingInfo()
            self.removeAVAudioSession()
        }
    }
}

// MARK: - Command Center
extension PlayerProvider {
    private func updateCommandCenter() {
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = isNextPodcastAvailable()
    }
    
    private func setupCommandCenter() {
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.podcastPlay()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.podcastPlay()
            return .success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.podcastPrevious()
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.podcastNext()
            return .success
        }
    }
    
    private func removeCommandCenter() {
        MPRemoteCommandCenter.shared().playCommand.isEnabled = false
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = false
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = false
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = false
        MPRemoteCommandCenter.shared().playCommand.removeTarget(nil)
        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(nil)
        MPRemoteCommandCenter.shared().previousTrackCommand.removeTarget(nil)
        MPRemoteCommandCenter.shared().nextTrackCommand.removeTarget(nil)
    }
}

// MARK: - Observers
extension PlayerProvider {
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context == &playbackLikelyToKeepUpContext {
            guard let safeItem = self.podcastPlayer.currentItem else {
                return
            }
            self.state = .loading(!safeItem.isPlaybackLikelyToKeepUp)
        }
    }
    
    @objc private func playerItemDidReachEnd(_ sender: NSNotification) {
        if isNextPodcastAvailable() {
            self.podcastNext()
        }
        else {
            self.pausePodcast()
            if let episodes = self.playlist,
               self.currentIndex == episodes.count - 1,
               let episodeSafe = episodes.first {
                self.currentIndex = 0
                self.loadPodcast(episode: episodeSafe, andPlay: false)
                self.podcastPlayer.seek(to: CMTime.zero)
            }
            else {
                self.podcastPlayer.seek(to: CMTime.zero)
            }
        }
    }
    
    @objc private func playerItemDidReadyToPlay(_ sender: Notification) {
        if let item = sender.object as? AVPlayerItem {
            if item.status == .readyToPlay {
                self.updateNowPlayingInfo()
                self.updateCommandCenter()
            }
            else if item.status == .failed {
                print("something went wrong. player.error should contain some information")
            }
        }
    }
    
    @objc private func handleSecondaryAudio(_ sender: Notification) {
        // Determine hint type
        guard let userInfo = sender.userInfo,
              let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
              let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else {
            return
        }
        if type == .begin {
            // Other app audio started playing - mute secondary audio
            self.pausePodcast()
        }
        else {
            // Other app audio stopped playing - restart secondary audio
            self.playPodcast()
        }
    }
    
    @objc private func handleInterruption(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeInt) else {
            return
        }
        switch type {
        case .began:
            self.pausePodcast()
        case .ended:
            if let optionInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionInt)
                if options.contains(.shouldResume) {
                    self.playPodcast()
                }
            }
            // do nothing (here if other case are added in future versions)
        @unknown default: break
        }
    }
}

