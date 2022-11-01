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
    
    func searchEpisodes(q: String, completion: (Result<Void, Error>) -> Void) {
        
    }
    
    func downloadEpisode(at index: Int, completion: (Result<Bool, Error>) -> Void) {
        
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
        let date = filteredEpisodes[index].pubDate
        return date.description
    }
    
    func episodeTitle(at index: Int) -> String {
        return filteredEpisodes[index].title
    }
    
    func episodeDescription(at index: Int) -> String {
        return filteredEpisodes[index].description
    }
    
    func episode(at index: Int) -> Episode {
        return filteredEpisodes[index]
    }
}
