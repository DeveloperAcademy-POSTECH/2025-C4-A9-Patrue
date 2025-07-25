//
//  GraphView.swift
//  SubwayCongestion
//
//  Created by 최희진 on 7/25/25.
//
import SwiftUI
import Charts

struct GraphView: View {
    let predicts: [PredictModel]
    let currentHour = 12
    
    var body: some View {
           VStack(alignment: .leading) {
               Chart {
                   ForEach(predicts, id: \.self) { predict in
                       LineMark(
                        x: .value("시간", predict.timeline),
                        y: .value("인원수", predict.peopleCount)
                       )
                       .interpolationMethod(.catmullRom)
                       .lineStyle(StrokeStyle(lineWidth: 3))
                       .foregroundStyle(.green)
                   
                       PointMark(
                        x: .value("Time of day", predict.timeline),
                        y: .value("UV index", predict.peopleCount)
                       )
                       .symbolSize(CGSize(width: 14, height: 14))
                       .foregroundStyle(.green)
                       .accessibilityHidden(true)
                       
                       
                       PointMark(
                        x: .value("시간", predict.timeline),
                        y: .value("인원수", predict.peopleCount)
                       )
                       .symbolSize(CGSize(width: 6, height: 6))
                       .foregroundStyle(predict.timeline == currentHour ? .green : .white)
                       .accessibilityLabel("Now")
                   }
                   
               
                   RuleMark(x: .value("현재 위치", currentHour))
                       .lineStyle(StrokeStyle(lineWidth: 2))
                       .foregroundStyle(.black)
                   
               }
               .chartYAxis {
                   
                   AxisMarks(
                    format: .number,
                    preset: .aligned,
                    values: [0, 3000, 6000, 9000]
                   )
                   
                   AxisMarks(preset: .aligned, position: .leading, values: [0, 3000, 6000, 9000]) { value in
                       AxisValueLabel(congestionLabel(for: Int64(value.as(Int.self) ?? 0)))
                   }
               }
               .chartXScale(domain: 5...24)
               .chartXAxis {
                   AxisMarks(values: Array(stride(from: 5, to: 24, by: 6))) { hour in
                       if let hourValue = hour.as(Int.self) {
                           AxisValueLabel("\(hourValue)시")
                       }
                   }
               }
               .frame(height: 350)
           }
    }
       
       func congestionLabel(for peopleCount: Int64) -> String {
           switch peopleCount {
           case 0..<3000: return ""
           case 3000..<6000: return "여유"
           case 6000..<9000: return "보통"
           case 9000...: return "혼잡"
           default: return ""
           }
       }
}

//#Preview {
//    CalendarView()
//}
