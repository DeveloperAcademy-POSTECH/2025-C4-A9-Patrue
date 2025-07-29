//
//  CongestionWidget.swift
//  CongestionWidget
//
//  Created by 최희진 on 7/28/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: @preconcurrency TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), passengers: 10000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), passengers: 10000)
        completion(entry)
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // ModelContainer와 ModelContext 생성
        let container = predictionContainer
        let modelContext = ModelContext(container)
        
        let calendar = Calendar.current
        
        let currentDate = Date()
        
        // 현재 날짜 정보 추출
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentDay = calendar.component(.day, from: currentDate)
        let rawCurrentHour = calendar.component(.hour, from: currentDate)
        
        // 현재시간이 오전 5시(05:00) 이전이면 오전 5시로 설정
        let currentHour = rawCurrentHour < 5 ? 5 : rawCurrentHour
        
        // 5시간 동안의 엔트리 생성
        for hourOffset in 0..<5 {
            let targetHour = currentHour + hourOffset
            
            // 24시간을 넘어가는 경우 처리 (간단히 하루 내에서만 처리)
            let adjustedHour = targetHour % 24
            
            // 분과 초를 0으로 설정한 정확한 시간 생성
            var dateComponents = DateComponents()
            dateComponents.year = currentYear
            dateComponents.month = currentMonth
            dateComponents.day = currentDay
            dateComponents.hour = adjustedHour
            dateComponents.minute = 0
            dateComponents.second = 0
            
            let entryDate = calendar.date(from: dateComponents)!
            
            // SwiftData에서 해당 시간의 예측 데이터 조회
            let fetchDescriptor = FetchDescriptor<Prediction>(
                predicate: #Predicate<Prediction> { prediction in
                    prediction.year == currentYear &&
                    prediction.month == currentMonth &&
                    prediction.day == currentDay &&
                    prediction.timeline == adjustedHour
                }
            )
            
            do {
                let predictions = try modelContext.fetch(fetchDescriptor)
                
                // 해당 시간의 예측 데이터가 있으면 사용, 없으면 기본값 사용
                let passengers = predictions.first?.passengers ?? 10000
                
                let entry = SimpleEntry(date: entryDate, passengers: passengers)
                entries.append(entry)
                print(entries)
                
            } catch {
                // 에러 발생 시 기본값으로 엔트리 생성
                print("Failed to fetch prediction data: \(error)")
                let entry = SimpleEntry(date: entryDate, passengers: 10000)
                entries.append(entry)
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let passengers: Int
}

struct CongestionWidgetEntryView : View {
    
    var entry: Provider.Entry
    @Query(sort: [
        SortDescriptor(\Prediction.month),
        SortDescriptor(\Prediction.day),
        SortDescriptor(\Prediction.timeline),
    ])
    var predictions: [Prediction]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5){
                Image(systemName: "location.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
                
                Text("잠실역")
                    .font(.system(size: 10, weight: .regular))
            }
            
            Spacer().frame(height: 5)
            
            Text(formattedTimeRange(from: entry.date))
                .font(.system(size: 18, weight: .bold))
            
            Text(descriptionForCongestion(entry.passengers))
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.gray4)
            
            Spacer()
            
            Image(.rowGraph)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    private func formattedTimeRange(from date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let nextHour = hour + 1
        
        return String(format: "%02d~%02d시", hour, nextHour)
    }
    
    private func descriptionForCongestion(_ passengers: Int) -> String {
        switch passengers {
        case 0 ..< 9000: return CongestionLabel.row.rawValue
        case 9000 ..< 21000: return CongestionLabel.middle.rawValue
        case 21000...: return CongestionLabel.high.rawValue
        default: return ""
        }
    }
}

struct CongestionWidget: Widget {
    let kind: String = " "

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CongestionWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(predictionContainer)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    CongestionWidget()
} timeline: {
    SimpleEntry(date: .now, passengers: 10000)
    SimpleEntry(date: .now, passengers: 10000)
}
