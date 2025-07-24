//
//  MockData.swift
//  MLTest
//
//  Created by 최희진 on 7/23/25.
//

import Foundation
import SwiftData

@Model
class MockData {
    var year: Int64
    var month: Int64
    var day: Int64
    var timeline: Int64
    var isAnnualOutlier: Int64
    var isHoliday: Int64

    init(year: Int64, month: Int64, day: Int64, timeline: Int64, isAnnualOutlier: Int64, isHoliday: Int64) {
        self.year = year
        self.month = month
        self.day = day
        self.timeline = timeline
        self.isAnnualOutlier = isAnnualOutlier
        self.isHoliday = isHoliday
    }
}
