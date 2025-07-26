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
    
    @Binding private var selectedDate: Date // 상태 인포그래픽이 참조해야 하기 때문에 바인딩 처리
    @State private var passengers: Int? = nil
    @State private var xPosition: CGFloat? = nil
    @State private var isDraggingEnabled = false
    
    private let calendar = Calendar.current

    init(data: [Prediction], currentDate: Date, selectedDate: Binding<Date>) {
        self.data = data
        self.currentDate = currentDate
        self._selectedDate = selectedDate //바인딩으로 주입 받기 때문에 초기화 불가능.
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Chart {
                chartMarks()
                
                RuleMark(x: .value("현재 위치", adjustedForRuleMark(roundedToHour(selectedDate))))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(.black)

                if currentDate == roundedToHour(Date()) {
                    RectangleMark(
                        xStart: .value("시작", startTimeAt4AM),
                        xEnd: .value("선택된 시각", roundedToHour(currentDate))
                    )
                    .foregroundStyle(.gray3)
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
            .symbolSize(CGSize(width: 12, height: 12))
            .foregroundStyle(point.asDate == roundedToHour(Date()) ? .blue : .green)
            .accessibilityHidden(true)

            PointMark(
                x: .value("Time", point.asDate),
                y: .value("Passengers", point.passengers)
            )
            .symbolSize(CGSize(width: 5, height: 5))
            .foregroundStyle(colorForPoint(date: point.asDate))
        }
    }
    
    private func overlayInfoText() -> some View {
        Group {
            if let xPosition {
                VStack {
                    Text(formattedTime(selectedDate, format: "a h:mm"))
                        .font(.footnote)
                        .fontWeight(.regular)
                    Text(descriptionForCongestion(passengers ?? 0))
                        .font(.body)
                        .fontWeight(.bold)
                }
                .background(Color.white)
                .position(x: xPosition, y: -30)
            }
        }
    }
    
    private func overlayGesture(proxy: ChartProxy) -> some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            isDraggingEnabled = true
                        }
                        .sequenced(before: DragGesture())
                        .onChanged { value in
                            switch value {
                            case .second(true, let dragValue?):
                                if isDraggingEnabled {
                                    handleDrag(value: dragValue, proxy: proxy, geo: geo)
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { _ in
                            isDraggingEnabled = false
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


