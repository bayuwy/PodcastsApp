//
//  DownloadsViewModel.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 04/11/22.
//

import Foundation

class DownloadsViewModel {
    private var episodes: [Episode] = []
    private var filteredEpisodes: [Episode] = []
    
    func loadDownloads(completion: @escaping (Result<Void, Error>) -> Void) {
        episodes = UserDefaults.standard.downloadedEpisodes()
        filteredEpisodes = episodes
        completion(.success(()))
    }
    
    func episodeIndex(where streamUrl: String) -> Int? {
        return filteredEpisodes.firstIndex { $0.streamUrl == streamUrl }
    }
    
    func searchEpisodes(q: String, completion: (Result<Void, Error>) -> Void) {
        if q.isEmpty {
            filteredEpisodes = episodes
        }
        else {
            filteredEpisodes = episodes.filter({ episode in
                return episode.epTitle.lowercased().range(of: q.lowercased()) != nil
                || episode.epAuthor.lowercased().range(of: q.lowercased()) != nil
            })
            completion(.success(()))
        }
    }
}

extension DownloadsViewModel {
    var numberOfEpisodes: Int {
        return filteredEpisodes.count
    }
    
    func episodeImagUrl(at index: Int) -> String {
        return filteredEpisodes[index].imageUrl
    }
    
    func episodePubDate(at index: Int) -> String {
        let date = filteredEpisodes[index].publishDate
        return date.string(format: "d MMMM yyyy")
    }
    
    func episodeTitle(at index: Int) -> String {
        return filteredEpisodes[index].epTitle
    }
    
    func episodeDescription(at index: Int) -> String {
        return filteredEpisodes[index].epDescription
    }
    
    func episode(at index: Int) -> Episode {
        return filteredEpisodes[index]
    }
}
