//
//  Episode.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 01/11/22.
//

import Foundation

protocol Episode {
    var title: String { get }
    var pubDate: Date { get }
    var description: String { get }
    var author: String { get }
    var streamUrl: String { get }
    var imageUrl: String { get }
    var fileUrl: String? { get }
}
