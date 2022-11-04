//
//  DownloadedEpisode.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 04/11/22.
//

import Foundation

struct DownloadedEpisode: Codable, Episode {
    var epTitle: String
    var publishDate: Date
    var epDescription: String
    var epAuthor: String
    var streamUrl: String
    var imageUrl: String
    var fileUrl: String?
    
    init(episode: Episode) {
        self.epTitle = episode.epTitle
        self.publishDate = episode.publishDate
        self.epDescription = episode.epDescription
        self.epAuthor = episode.epAuthor
        self.streamUrl = episode.streamUrl
        self.imageUrl = episode.imageUrl
    }
}
