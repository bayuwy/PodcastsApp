//
//  UserDefaultsExtension.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 04/11/22.
//

import Foundation

extension UserDefaults {
    static let downloadedEpisodesKey: String = "kDownloadedEpisodesKey"
    
    func downloadedEpisodes() -> [DownloadedEpisode] {
        guard let data = self.data(forKey: UserDefaults.downloadedEpisodesKey) else {
            return []
        }
        
        do {
            let episodes = try JSONDecoder().decode([DownloadedEpisode].self, from: data)
            return episodes
        }
        catch {
            return []
        }
    }
 
    func downloadEpisode(_ episode: Episode) {
        let downloadedEpisode = DownloadedEpisode(episode: episode)
        
        var episodes = self.downloadedEpisodes()
        episodes.insert(downloadedEpisode, at: 0)
        
        do {
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
            
            NotificationCenter.default.post(name: .downloadAdded, object: nil)
        }
        catch {
            print("Failed to encode: \(error)")
        }
    }
    
}
