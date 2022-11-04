//
//  DownloadViewModel.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 04/11/22.
//

import Foundation

class DownloadViewModel {
    private var episodes: [Episode] = []
    private var filteredEpisodes: [Episode] = []
    
    func loadDownloads(completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    func searchEpisodes(q: String, completion: (Result<Void, Error>) -> Void) {
        
    }
}

extension DownloadViewModel {
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
