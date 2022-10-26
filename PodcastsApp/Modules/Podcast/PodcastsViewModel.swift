//
//  PodcastsViewModel.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import Foundation

class PodcastsViewModel {
    private var podcasts: [Podcast] = []
    
    func searchPodcasts(q: String, completion: @escaping (Result<Void, Error>) -> Void) {
        APIService.shared.searchPodcasts(q: q) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let podcasts):
                    self?.podcasts = podcasts
                    completion(.success(()))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    var numberOfPodcasts: Int {
        return podcasts.count
    }
    
    func podcastImagUrl(at index: Int) -> String {
        return podcasts[index].artworkUrl600
    }
    
    func podcastTrackName(at index: Int) -> String {
        return podcasts[index].trackName
    }
    
    func podcastArtistName(at index: Int) -> String {
        return podcasts[index].artistName
    }
    
    func podcastTrackCount(at index: Int) -> String {
        return "\(podcasts[index].trackCount) Episode(s)"
    }
    
    func podcast(at index: Int) -> Podcast {
        return podcasts[index]
    }
}
