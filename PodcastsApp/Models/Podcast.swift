//
//  Podcast.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import Foundation

protocol Podcast {
    var trackId: Int { get }
    var trackName: String { get }
    var trackCount: Int { get }
    var artistName: String { get }
    var artworkUrl600: String { get }
    var feedUrl: String { get }
}

struct Podcast_: Decodable, Podcast {
    var trackId: Int
    var trackName: String
    var trackCount: Int
    var artistName: String
    var artworkUrl600: String
    var feedUrl: String
    
    enum CodingKeys: String, CodingKey {
        case trackId
        case trackName
        case trackCount
        case artistName
        case artworkUrl600
        case feedUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trackId = try container.decodeIfPresent(Int.self, forKey: .trackId) ?? 0
        self.trackName = try container.decodeIfPresent(String.self, forKey: .trackName) ?? ""
        self.trackCount = try container.decodeIfPresent(Int.self, forKey: .trackCount) ?? 0
        self.artistName = try container.decodeIfPresent(String.self, forKey: .artistName) ?? ""
        self.artworkUrl600 = try container.decodeIfPresent(String.self, forKey: .artworkUrl600) ?? ""
        self.feedUrl = try container.decodeIfPresent(String.self, forKey: .feedUrl) ?? ""
    }
}
