//
//  ChartTestView.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//


import Charts
import SwiftUI

struct CongestionGraph: View {
    var data: [Prediction]
    @State private var selectedDate: Date = Date()//현재 날짜로 초기화
    @State private var passengers: Int? = nil
    @State private var xPosition: CGFloat? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("인원수: \(passengers)")
            
            Chart {
                chartMarks()
                
                RuleMark(x: .value("현재 위치", selectedDate))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(.black)

                if let firstDate = data.first?.asDate {
                    RectangleMark(
                        xStart: .value("시작", firstDate),
                        xEnd: .value("선택된 시각", Date())
                    )
                    .foregroundStyle(.gray.opacity(0.2))
                    .accessibilityHidden(true)
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
                overlayGesture(proxy: proxy)
            }
            .frame(height: 300)
        }
        .overlay(alignment: .topLeading) {
            overlayInfoText()
        }
        .padding(.horizontal, 20)
        .onAppear {
            print("\(data[19].month)-\(data[19].day)-\(data[19].timeline)-\(data[19].passengers)")
        }
    }
    
    // MARK: - Chart Marks
     @ChartContentBuilder
     private func chartMarks() -> some ChartContent {
         ForEach(data, id: \.id) { point in
             LineMark(
                 x: .value("Time", point.asDate),
                 y: .value("Passengers", point.passengers)
             )
             .interpolationMethod(.catmullRom)
             .lineStyle(StrokeStyle(lineWidth: 3))
             .foregroundStyle(.green)

             PointMark(
                 x: .value("Time", point.asDate),
                 y: .value("Passengers", point.passengers)
             )
             .symbolSize(CGSize(width: 14, height: 14))
             .foregroundStyle(.green)
             .accessibilityHidden(true)

             PointMark(
                 x: .value("Time", point.asDate),
                 y: .value("Passengers", point.passengers)
             )
             .symbolSize(CGSize(width: 6, height: 6))
             .foregroundStyle(point.asDate == selectedDate ? .green : .white)
             .accessibilityLabel("Now")
         }
     }
    
    private func overlayInfoText() -> some View {
        Group {
            if let xPosition {
                Text("\(timeFormatter(date: selectedDate))\n혼잡")
                    .font(.caption)
                    .background(Color.white)
                    .cornerRadius(4)
                    .multilineTextAlignment(.center)
                    .position(x: xPosition)
            }
        }
    }
    
    private func overlayGesture(proxy: ChartProxy) -> some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            handleDrag(value: value, proxy: proxy, geo: geo)
                        }
                )
        }
    }
}

extension CongestionGraph{
    private func handleDrag(value: DragGesture.Value, proxy: ChartProxy, geo: GeometryProxy) {
        let originX = geo[proxy.plotAreaFrame].origin.x
        let localX = value.location.x - originX
        
        guard let currentDate: Date = proxy.value(atX: localX) else { return }
        
        if let closest = data.min(by: { abs($0.asDate.timeIntervalSince(currentDate)) < abs($1.asDate.timeIntervalSince(currentDate)) }) {
            selectedDate = closest.asDate
            passengers = closest.passengers
            
            if let xPos = proxy.position(forX: closest.asDate) {
                xPosition = xPos + originX
            }
        }
    }
    
    private func descriptionForCongestion(_ passengers: Int) -> String {
        switch passengers {
        case 0..<3000: return ""
        case 3000..<6000: return "여유"
        case 6000..<9000: return "보통"
        case 9000...: return "혼잡"
        default: return ""
        }
    }
    
    private func timeFormatter(date: Date) -> String{
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
