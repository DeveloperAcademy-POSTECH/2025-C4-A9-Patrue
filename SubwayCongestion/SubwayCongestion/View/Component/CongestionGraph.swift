//
//  ChartTestView.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//


import Charts
import SwiftUI

struct CongestionGraph: View {
    let data: [Prediction]
    let currentDate: Date
    
    @State private var selectedDate: Date
    @State private var passengers: Int? = nil
    @State private var xPosition: CGFloat? = nil

    init(data: [Prediction], currentDate: Date) {
        self.data = data
        self.currentDate = currentDate
        _selectedDate = State(initialValue: roundedToHour(currentDate))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("인원수: \(String(describing: passengers))")
            
            Chart {
                chartMarks()
                
                RuleMark(x: .value("현재 위치", adjustedForRuleMark(selectedDate)))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(.black)

                if currentDate == roundedToHour(Date()){
                    RectangleMark(
                        xStart: .value("시작", startAtFourAM(date: currentDate)),
                        xEnd: .value("선택된 시각", roundedToHour(currentDate))
                    )
                    .foregroundStyle(.gray.opacity(0.2))
                    .accessibilityHidden(true)
                }
            }
            .chartXScale(domain: xAxisDomain)
            .chartXAxis {
                AxisMarks(values: xAxisTickDates) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let dateValue = value.as(Date.self) {
                            Text(formattedTime(dateValue)) // 오전/오후 시간 출력
                        }
                    }
                }
            }
            .chartYScale(range: .plotDimension(padding: 2))
            .chartYAxis {
                AxisMarks(values: [0, 4000, 7000, 10000]) { _ in
                    AxisGridLine()
                    AxisTick()
                }
                
                AxisMarks(preset: .inset, position: .leading, values: [0, 4000, 7000, 10000]) { value in
                    AxisValueLabel(labelForCongestion(value.as(Int.self) ?? 0))
                        .offset(y: 20)
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
        .onChange(of: currentDate) {
            xPosition = nil
            selectedDate = roundedToHour(currentDate)
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
             .foregroundStyle(point.asDate == roundedToHour(Date()) ? .blue : .green)
             .accessibilityHidden(true)

             PointMark(
                 x: .value("Time", point.asDate),
                 y: .value("Passengers", point.passengers)
             )
             .symbolSize(CGSize(width: 6, height: 6))
             .foregroundStyle(colorForPoint(date: point.asDate))
             .accessibilityLabel("Now")
         }
     }
    
    // 날짜에 따라 색상 반환
    private func colorForPoint(date: Date) -> Color {
        if date == roundedToHour(Date()) {
            return .blue // 오늘 날짜인 경우
        } else if date == selectedDate {
            return .green // 선택된 날짜
        } else {
            return .white // 기본
        }
    }
    
    private func overlayInfoText() -> some View {
        Group {
            if let xPosition {
                Text("\(formattedTime(selectedDate, format: "a h:mm시"))\n\(descriptionForCongestion(passengers ?? 0))")
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

// MARK: - Helper Methods

extension CongestionGraph{
    
    private var xAxisDomain: ClosedRange<Date> {
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: currentDate)!

        // 다음 날 0시로 설정
        let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        let end = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: nextDay)!

        return start...end
    }
    
    private var xAxisTickDates: [Date] {
        let calendar = Calendar.current
        let hours = [6, 12, 18, 0]  // 표시할 시각들
        return hours.compactMap { hour in
            if hour == 0 {
                // 다음 날 0시
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextDay)
                } else {
                    return nil
                }
            } else {
                // 오늘의 6시, 12시, 18시
                return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: currentDate)
            }
        }
    }
    
    private func startAtFourAM(date: Date) -> Date {
        let calendar = Calendar.current
        if let date = calendar.date(
            bySettingHour: 4,
            minute: 0,
            second: 0,
            of: currentDate
        ){
            return date
        }
        return date
    }
    
    private func adjustedForRuleMark(_ date: Date) -> Date {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        if hour < 5 && hour != 0{
            // 오전 5시로 고정
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = 5
            components.minute = 0
            components.second = 0
            return calendar.date(from: components)!
        } else {
            // 그대로 사용
            return date
        }
    }
    
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
        case 0..<4000: return "여유"
        case 4000..<7000: return "보통"
        case 7000...: return "혼잡"
        default: return ""
        }
    }
    
    private func labelForCongestion(_ passengers: Int) -> String {
        switch passengers {
        case 0..<4000: return ""
        case 4000..<7000: return "여유"
        case 7000..<10000: return "보통"
        case 10000...: return "혼잡"
        default: return ""
        }
    }

    private func formattedTime(_ date: Date, format: String = "a h시") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

func roundedToHour(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    return calendar.date(from: components)!
}


