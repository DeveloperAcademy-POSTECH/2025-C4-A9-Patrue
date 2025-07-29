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
        SimpleEntry(date: Date(), passengers: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), passengers: 0)
        completion(entry)
    }
    
    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let container = predictionContainer
        let modelContext = ModelContext(container)
        let calendar = Calendar.current
        let currentDate = Date()

        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        let currentHour = calendar.component(.hour, from: currentDate)

        let targetTimeline: Int
        let entryDate: Date

        if currentHour < 5 {
            // 오전 5시로 고정
            targetTimeline = 5
            entryDate = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: currentDate) ?? Date()
        } else {
            // 현재 시각 그대로 사용
            targetTimeline = currentHour
            entryDate = calendar.date(bySettingHour: currentHour, minute: 0, second: 0, of: currentDate) ?? Date()
        }

        let fetchDescriptor = FetchDescriptor<Prediction>(
            predicate: #Predicate<Prediction> { prediction in
                prediction.year == year &&
                prediction.month == month &&
                prediction.day == day &&
                prediction.timeline == targetTimeline
            }
        )

        do {
            let predictions = try modelContext.fetch(fetchDescriptor)

            if let prediction = predictions.first {
                print("매칭된 timeline: \(prediction.timeline), passengers: \(prediction.passengers)")
                let entry = SimpleEntry(date: entryDate, passengers: prediction.passengers)
                entries.append(entry)
            } else {
                print("예측 데이터 없음. 기본값 사용")
                let entry = SimpleEntry(date: entryDate, passengers: 0)
                entries.append(entry)
            }

        } catch {
            print("예측 데이터 가져오기 실패: \(error)")
            let fallbackEntry = SimpleEntry(date: entryDate, passengers: 0)
            entries.append(fallbackEntry)
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
            
            fetchGraphImage(entry.passengers)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    private func fetchGraphImage(_ passengers: Int) -> Image{
        switch passengers {
        case 0 ..< 9000: return Image(.rowGraph)
        case 9000 ..< 21000: return Image(.middleGraph)
        case 21000...: return Image(.highGraph)
        default: return Image("")
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
    let kind: String = "com.patrue.tabular.widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CongestionWidgetEntryView(entry: entry)
                .containerBackground(.white, for: .widget)
                .modelContainer(predictionContainer)
        }
        .configurationDisplayName("덜붐벼")
        .description("덜붐벼 위젯입니다!")
    }
}

#Preview(as: .systemSmall) {
    CongestionWidget()
} timeline: {
    SimpleEntry(date: .now, passengers: 10000)
    SimpleEntry(date: .now, passengers: 10000)
}
