//
//  DPodcast+CoreDataProperties.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 28/10/22.
//
//

import Foundation
import CoreData


extension DPodcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DPodcast> {
        return NSFetchRequest<DPodcast>(entityName: "DPodcast")
    }

    @NSManaged public var trackId_: Int64
    @NSManaged public var trackName: String
    @NSManaged public var trackCount_: Int16
    @NSManaged public var artistName: String
    @NSManaged public var artwork: String
    @NSManaged public var feedUrl: String
    @NSManaged public var isFavorited: Bool

}

extension DPodcast : Identifiable {

}
