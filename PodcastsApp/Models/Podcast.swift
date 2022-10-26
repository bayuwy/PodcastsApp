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
