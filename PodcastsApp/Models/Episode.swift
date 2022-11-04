//
//  Episode.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 01/11/22.
//

import Foundation
import FeedKit

protocol Episode {
    var epTitle: String { get }
    var publishDate: Date { get }
    var epDescription: String { get }
    var epAuthor: String { get }
    var streamUrl: String { get }
    var imageUrl: String { get }
    
    var fileUrl: String? { get }
}

extension RSSFeedItem: Episode {
    var epTitle: String {
        return title ?? ""
    }
    
    var publishDate: Date {
        return pubDate ?? Date(timeIntervalSince1970: 0)
    }
    
    var epDescription: String {
        return iTunes?.iTunesSubtitle ?? description ?? ""
    }
    
    var epAuthor: String {
        return iTunes?.iTunesAuthor ?? author ?? ""
    }
    
    var streamUrl: String {
        return enclosure?.attributes?.url ?? ""
    }
    
    var imageUrl: String {
        return iTunes?.iTunesImage?.attributes?.href ?? ""
    }
    
    var fileUrl: String? {
        return nil
    }
}
