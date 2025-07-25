//
//  PredictData.swift
//  MLTest
//
//  Created by 최희진 on 7/23/25.
//

import Foundation
import SwiftData

@Model
class PredictData {
    var year: Int64
    var month: Int64
    var day: Int64
    var timeline: Int64
    var peopleCount: Int64

    init(year: Int64, month: Int64, day: Int64, timeline: Int64, peopleCount: Int64) {
        self.year = year
        self.month = month
        self.day = day
        self.timeline = timeline
        self.peopleCount = peopleCount
    }
}

struct PredictModel: Hashable {
    let year: Int64
    let month: Int64
    let day: Int64
    let timeline: Int64
    let peopleCount: Int64
}

