//
//  Prediction.swift
//  SubwayCongestion
//
//  Created by Paidion on 7/24/25.
//

import Foundation
import SwiftData

@Model
final class Prediction: Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var day: Int
    var timeline: Int
    var passengers: Int

    var asDate: Date {
        let components = DateComponents(
            year: year,
            month: month,
            day: day,
            hour: timeline
        )
        return Calendar.current.date(from: components)!
    }

    init(year: Int, month: Int, day: Int, timeline: Int, passengers: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.timeline = timeline
        self.passengers = passengers
    }
}
