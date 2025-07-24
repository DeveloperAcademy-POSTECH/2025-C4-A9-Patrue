//
//  Timeline.swift
//  MLTest
//
//  Created by 최희진 on 7/23/25.
//


enum Timeline: Int64, CaseIterable {
    case before6 = 0 // 05시 이전
    case hour6 = 1
    case hour7 = 2
    case hour8 = 3
    case hour9 = 4
    case hour10 = 5
    case hour11 = 6
    case hour12 = 7
    case hour13 = 8
    case hour14 = 9
    case hour15 = 10
    case hour16 = 11
    case hour17 = 12
    case hour18 = 13
    case hour19 = 14
    case hour20 = 15
    case hour21 = 16
    case hour22 = 17
    case hour23 = 18
    case hour24 = 19 // 24시 이후
    
    /// 해당 타임라인의 실제 시간 (예: hour6 -> 6)
    var hour: Int64 {
        return self.rawValue + 5
    }
}

