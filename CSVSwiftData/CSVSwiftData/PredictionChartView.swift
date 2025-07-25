//
//  PredictionChartView.swift
//  CSVSwiftData
//
//  Created by 서세린 on 7/24/25.
//

import SwiftUI
import Charts
import _SwiftData_SwiftUI

struct PredictionChartView: View {
    //    var predictions: [PredictionItem]
    @Query var predictions: [PredictionItem]
    
    init(year: Int, month: Int, day: Int) {
        _predictions = Query(filter: #Predicate<PredictionItem> {
            $0.year == year && $0.month == month && $0.day == day
        }, sort: \.startHour)
    }
    
    var body: some View {
        Chart(predictions) { item in
            LineMark(
                //                x: .value("시간대", item.timeSlot),
                x: .value("시간", item.startHour),
                y: .value("인원 수", item.peopleCount)
            )
            .foregroundStyle(.green)
            .symbol(Circle())
        }
        .frame(height: 250)
        .padding()
        .chartXScale(domain: 6...24) // ✅ x축 범위를 06~24로 고정
        .chartXAxis {
            AxisMarks(values: Array(6...24)) { hour in
                AxisValueLabel {
                    Text("\(hour)")
                }
            }
        }
    }
}
