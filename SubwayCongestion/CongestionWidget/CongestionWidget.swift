//
//  CongestionWidget.swift
//  CongestionWidget
//
//  Created by 최희진 on 7/28/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), passengers: 10000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), passengers: 10000)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, passengers: 10000)
            entries.append(entry)
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
            
            Text(entry.date, style: .time)
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
    let kind: String = "CongestionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CongestionWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
