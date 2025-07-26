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
    
    private let calendar = Calendar.current
    
    init(data: [Prediction], currentDate: Date) {
        self.data = data
        self.currentDate = currentDate
        _selectedDate = State(initialValue: roundedToHour(currentDate))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("인원수: \(passengers ?? 0)")
            
            Chart {
                chartMarks()
                
                RuleMark(x: .value("현재 위치", adjustedForRuleMark(selectedDate)))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(.black)

                if currentDate == roundedToHour(Date()) {
                    RectangleMark(
                        xStart: .value("시작", startTimeAt4AM),
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
                            Text(formattedTime(dateValue))
                        }
                    }
                }
            }
            .chartYScale(domain: 0...13050)
            .chartYAxis {
                AxisMarks(values: [0, 4000, 7000, 13000]) { _ in
                    AxisGridLine()
                    AxisTick()
                }
                
                AxisMarks(preset: .inset, position: .leading, values: [0, 4000, 7000, 13000]) { value in
                    AxisValueLabel(labelForCongestion(value.as(Int.self) ?? 0))
                        .offset(y: 23)
                }
            }
            .chartOverlay { proxy in
                overlayGesture(proxy: proxy)
            }
            .frame(height: 300)
            .background(.gray2)
            .clipShape(.rect(cornerRadius: 22))
        }
        .overlay(alignment: .topLeading) {
            overlayInfoText()
        }
        .padding(.horizontal, 20)
        .onChange(of: currentDate) {
            xPosition = nil
            selectedDate = roundedToHour(currentDate)
            for prediction in data {
                print("\(prediction.asDate)시간대: \(prediction.passengers)명")
            }
        }
    }
}

// MARK: - Chart Components

extension CongestionGraph {
    
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
            .accessibilityLabel(point.asDate == roundedToHour(Date()) ? "Now" : "")
        }
    }
    
    private func overlayInfoText() -> some View {
        Group {
            if let xPosition {
                VStack {
                    Text(formattedTime(selectedDate, format: "a h:mm시"))
                    Text(descriptionForCongestion(passengers ?? 0))
                }
                .font(.caption)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)
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

// MARK: - Calendar & Date Helpers

extension CongestionGraph {
    
    private var xAxisDomain: ClosedRange<Date> {
        let start = createDate(hour: 4, minute: 0, for: currentDate)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        let end = createDate(hour: 1, minute: 0, for: nextDay)
        return start...end
    }
    
    private var xAxisTickDates: [Date] {
        let hours = [6, 12, 18, 0]
        return hours.compactMap { hour in
            if hour == 0 {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                return createDate(hour: 0, minute: 0, for: nextDay)
            } else {
                return createDate(hour: hour, minute: 0, for: currentDate)
            }
        }
    }
    
    private var startTimeAt4AM: Date {
        createDate(hour: 4, minute: 0, for: currentDate)
    }
    
    private func createDate(hour: Int, minute: Int, for date: Date) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
    
    private func adjustedForRuleMark(_ date: Date) -> Date {
        let hour = calendar.component(.hour, from: date)
        
        guard hour < 5 && hour != 0 else { return date }
        
        return createDate(hour: 5, minute: 0, for: date)
    }
}

// MARK: - Interaction Handlers

extension CongestionGraph {
    
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
    
    private func colorForPoint(date: Date) -> Color {
        if date == roundedToHour(Date()) {
            return .blue
        } else if date == selectedDate {
            return .green
        } else {
            return .white
        }
    }
}

// MARK: - Congestion Level Helpers

extension CongestionGraph {

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
        case 7000..<13000: return "보통"
        case 13000...: return "혼잡"
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


