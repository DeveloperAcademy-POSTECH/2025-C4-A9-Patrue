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
    
    @Query(sort: [
        SortDescriptor(\Prediction.month),
        SortDescriptor(\Prediction.day),
        SortDescriptor(\Prediction.timeline),
    ])
    var predictions: [Prediction]

    @State private var currentDate: Date = .now
    @State private var selectedDate: Date = .now//버튼 날짜 상태
    @State private var selectedGraphDate: Date = .now//graph 날짜 상태
    @State private var showGuideSheet: Bool = false

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
        }[0]
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 16) {
                    DateSelector(currentDate: $currentDate, selectedDate: $selectedDate)
                    Text(formattedDateString(selectedDate))
                    Divider()
                }
                .padding(.top)

                VStack {
                    // 1. 혼잡도 인포그래피
                    
                    //Infographics.swift를 불러오는 코드
                    Infographics(selectedDate: $selectedGraphDate, data: filteredPredictions)
                    
                    Spacer()
                    // 2. 혼잡도 차트
                    CongestionGraph(
                        data: filteredPredictions,
                        currentDate: mergeDateAndHour(date: selectedDate, timeSource: currentDate),
                        selectedDate: $selectedGraphDate // graph의 selectedDate를 바인딩으로 처리
                    )
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

func mergeDateAndHour(date: Date, timeSource: Date) -> Date {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let hourComponent = calendar.component(.hour, from: timeSource)

    var mergedComponents = dateComponents
    mergedComponents.hour = hourComponent
    mergedComponents.minute = 0
    mergedComponents.second = 0

    return calendar.date(from: mergedComponents)!
}

#Preview {
    ContentView()
}
