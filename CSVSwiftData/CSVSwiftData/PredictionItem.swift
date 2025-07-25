//
//  PredictionItem.swift
//  CSVSwiftData
//
//  Created by 서세린 on 7/24/25.
//

import Foundation
import SwiftData

//@Model
//class PredictionItem: Identifiable {
//    var id: UUID = UUID()
//    var year: Int
//    var month: Int
//    var day: Int
//    var timeSlot: String
//    var peopleCount: Int
//
//    init(year: Int, month: Int, day: Int, timeSlot: String, peopleCount: Int) {
//        self.year = year
//        self.month = month
//        self.day = day
//        self.timeSlot = timeSlot
//        self.peopleCount = peopleCount
//    }
//}
@Model
class PredictionItem: Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var day: Int
    var timeSlot: String
    var peopleCount: Int
    var startHour: Int  // ⬅️ 추가! 예: "06-07시간대" → 6

    init(year: Int, month: Int, day: Int, timeSlot: String, peopleCount: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.timeSlot = timeSlot
        self.peopleCount = peopleCount
        self.startHour = PredictionItem.extractHour(from: timeSlot) // 초기화 시 처리
    }

    static func extractHour(from timeSlot: String) -> Int {
        let parts = timeSlot.split(separator: "-")
        if let hourString = parts.first, let hour = Int(hourString) {
            return hour
        }
        return -1 // 예외 처리용 값
    }
}
