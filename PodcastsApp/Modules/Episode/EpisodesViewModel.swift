//
//  EpisodesViewModel.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 01/11/22.
//

import Foundation
 
class EpisodesViewModel {
    private let podcast: Podcast
    init(podcast: Podcast) {
        self.podcast = podcast
    }
    
    private var episodes: [Episode] = []
    private var filteredEpisodes: [Episode] = []
    
    var title: String {
        return podcast.trackName
    }
    
    func loadEpisodes(completion: @escaping (Result<Void, Error>) -> Void) {
        APIService.shared.fetchEpisodes(feedUrl: podcast.feedUrl) { [weak self] (result) in
            guard let safeSelf = self else { return }
            switch result {
            case .success(let episodes):
                safeSelf.episodes = episodes
                safeSelf.filteredEpisodes = episodes
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchEpisodes(q: String, completion: (Result<Void, Error>) -> Void) {
        
    }
    
    func downloadEpisode(at index: Int, completion: (Result<Bool, Error>) -> Void) {
        let episode = episode(at: index)
        UserDefaults.standard.downloadEpisode(episode)
        APIService.shared.downloadEpisode(episode)
    }
}

extension EpisodesViewModel {
    var numberOfEpisodes: Int {
        return filteredEpisodes.count
    }
    
    func episodeImagUrl(at index: Int) -> String {
        return filteredEpisodes[index].imageUrl
    }
    
    func episodePubDate(at index: Int) -> String {
        let date = filteredEpisodes[index].publishDate
        return date.description
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
