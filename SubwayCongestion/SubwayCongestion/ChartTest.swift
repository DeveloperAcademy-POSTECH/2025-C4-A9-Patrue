//
//  ChartTestView.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//


import Charts
import SwiftUI

struct ChartTestView: View {
    // [month, day, timeline]
    var data: [Prediction]
    @State private var selectedDate: Date? = nil
    @State private var passengers: Int? = nil
    @State private var xPosition: CGFloat? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("인원수: \(passengers)")
            
            Chart {
                ForEach(data, id: \.id) { dataPoint in
                    LineMark(
                        x: .value("Time of day", dataPoint.asDate),
                        y: .value("Passengers", dataPoint.passengers)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(.green)

                    PointMark(
                        x: .value("Time of day", dataPoint.asDate),
                        y: .value("Passengers", dataPoint.passengers)
                    )
                    .symbolSize(CGSize(width: 14, height: 14))
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)

                    PointMark(
                        x: .value("Time of day", dataPoint.asDate),
                        y: .value("Passengers", dataPoint.passengers)
                    )
                    .symbolSize(CGSize(width: 6, height: 6))
                    .foregroundStyle(dataPoint.asDate == selectedDate ? .green : .white)
                    .accessibilityLabel("Now")
                    
                    
                }
                
                if let selectedDate = selectedDate {
                    RuleMark(x: .value("현재 위치", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(.black)
                }else{
//                    RuleMark(x: .value("현재 위치", ))
//                        .lineStyle(StrokeStyle(lineWidth: 2))
//                        .foregroundStyle(.black)
                }
                
                if let selectedDate {
                    // 가장 첫 데이터의 날짜
                    if let firstDate = data.first?.asDate {
                        RectangleMark(
                            xStart: .value("시작", firstDate),
                            xEnd: .value("선택된 시각", selectedDate)
                        )
                        .foregroundStyle(.gray.opacity(0.2)) // 어두운 배경 효과
                        .accessibilityHidden(true)
                    }
                }
            }
            .chartYScale(range: .plotDimension(padding: 2))
            .chartYAxis {
                
                AxisMarks(
                 format: .number,
                 preset: .inset,
                 values: [0, 3000, 6000, 9000]
                )
                
                AxisMarks(preset: .inset, position: .leading, values: [0, 3000, 6000, 9000]) { value in
                    AxisValueLabel(descriptionForCongestion(value.as(Int.self) ?? 0))
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let originX = geo[proxy.plotAreaFrame].origin.x
                                    let currentX = value.location.x - originX
                                    
                                    // 좌표를 Date로 변환
                                    if let currentDate: Date = proxy.value(atX: currentX) {
                                        let closest = data.min(by: {
                                            abs($0.asDate.timeIntervalSince(currentDate)) < abs($1.asDate.timeIntervalSince(currentDate))
                                        })
                                        selectedDate = closest?.asDate
                                        
                                        if let selectedPrediction = data.first(where: { $0.asDate == selectedDate }) {
                                            passengers = selectedPrediction.passengers
                                        }
                                        
                                        if let selectedDate = selectedDate,
                                           let xPos = proxy.position(forX: selectedDate) {
                                            xPosition = xPos + originX // 전체 좌표계 기준 위치
                                        }
                                    }
                                }
                        )
                }
            }
            .frame(height: 300)
        }
        .overlay(alignment: .topLeading) {
            if let xPosition = xPosition,
               let selected = selectedDate {
                Text("\(timeFormatter(date: selected))\n혼잡")
                    .font(.caption)
                    .background(Color.white)
                    .cornerRadius(4)
                    .position(x: xPosition)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            print("\(data[19].month)-\(data[19].day)-\(data[19].timeline)-\(data[19].passengers)")
        }
    }
    
    func descriptionForCongestion(_ passengers: Int) -> String {
        switch passengers {
        case 0..<3000: return ""
        case 3000..<6000: return "여유"
        case 6000..<9000: return "보통"
        case 9000...: return "혼잡"
        default: return ""
        }
    }
    
    func timeFormatter(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm시"  // 오전/오후 h:mm시 형식

        let timeString = formatter.string(from: date)
        return timeString
    }
}

// #Preview {
//    ChartTestView()
// }
