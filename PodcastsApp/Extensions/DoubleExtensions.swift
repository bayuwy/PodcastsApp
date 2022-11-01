//
//  DoubleExtensions.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 01/11/22.
//

import Foundation

extension Double {
    var durationString: String {
        let ti = Int(self)

        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)

        if hours != 0 {
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        }
        else {
            return String(format: "%0.2d:%0.2d", minutes, seconds)
        }
    }
}
