//
//  ContentView.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/6/25.
//

import Charts
import CoreML
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
//    @Query var predictions: [Prediction]

    @Query(sort: [
        SortDescriptor(\Prediction.month),
        SortDescriptor(\Prediction.day),
        SortDescriptor(\Prediction.timeline),
    ])
    var predictions: [Prediction]

    @State private var currentDate: Date = .now
    @State private var selectedDate: Date = .now
    @State private var showGuideSheet: Bool = false
//    @State private var filteredPredictions: [Prediction] = []

    var filteredPredictions: [Prediction] {
        let calendar = Calendar.current
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let selectedDay = calendar.component(.day, from: selectedDate)

        return predictions.filter { item in
            item.month == selectedMonth && item.day == selectedDay
        }
    }

    var currentDatePrediction: Prediction {
        let calendar = Calendar.current
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let selectedDay = calendar.component(.day, from: selectedDate)
        let selectedTimeline = calendar.component(.hour, from: selectedDate)

        print("\(selectedMonth)-\(selectedDay)-\(selectedTimeline)")

        return predictions.filter { item in
            item.month == 8 && item.day == 1 && item.timeline == 5
//            item.month == selectedMonth && item.day == selectedDay && item.timeline + 5 == selectedTimeline
        }[0]
    }

//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    let allTimelines = Array(0 ... 23)

    var body: some View {
        NavigationStack {
            NavigationLink("Chart") {
                ChartTestView(data: filteredPredictions)
            }

            VStack {
                VStack(spacing: 16) {
                    DateSelector(currentDate: $currentDate, selectedDate: $selectedDate)
                    Text(formattedDateString(selectedDate))
                    Divider()
                }
                .padding(.top)

                VStack {
                    // 1. 혼잡도 인포그래피
                    VStack {
                        Text(formattedHour(currentDate))
                            .font(.title)
                            .fontWeight(.semibold)

                        Text("\(currentDatePrediction.timeline)시간대")
                        Text("승객수 \(currentDatePrediction.passengers)")
                    }
                    // 2. 혼잡도 차트
                    Chart(filteredPredictions) { prediction in
                        LineMark(
                            x: .value("시간", String(prediction.timeline) + "시간대"),
                            y: .value("승객 수", prediction.passengers)
                        )
                        .foregroundStyle(Color.green)
                    }
                    .padding(.all)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomStationTitle()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showGuideSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .accessibilityLabel("이용 안내")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showGuideSheet) {
                CongestionGuideSheet()
            }
            .onAppear {
                print(filteredPredictions)
            }
        }
    }
}

func formattedDateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy년 M월 d일 EEEE"
    return formatter.string(from: date)
}

func formattedHour(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "a h:00"
    return formatter.string(from: date)
}

#Preview {
    ContentView()
}
