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
    @Query(sort: [
        SortDescriptor(\Prediction.month),
        SortDescriptor(\Prediction.day),
        SortDescriptor(\Prediction.timeline),
    ])
    var predictions: [Prediction]
    private let calendar = Calendar.current

    @State private var currentDate: Date = .now
    @State private var selectedDate: Date = .now // 버튼 날짜 상태
    @State private var selectedGraphDate: Date = mergeDateAndHour(date: .now, timeSource: .now) // graph 날짜 상태
    @State private var showGuideSheet: Bool = false
    @State private var selectedIndex: Int = 0

    var filteredPredictions: [Prediction] {
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let selectedDay = calendar.component(.day, from: selectedDate)

        return predictions.filter { item in
            item.month == selectedMonth && item.day == selectedDay
        }
    }

    var mergedDate: Date {
        mergeDateAndHour(date: selectedDate, timeSource: currentDate)
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 16) {
                    DateSelector(currentDate: $currentDate, selectedDate: $selectedDate, selectedIndex: $selectedIndex)
                    Text(formattedDateString(selectedDate))
                    Divider()
                }
                .padding(.top)

                TabView(selection: $selectedIndex) {
                    ForEach(0 ..< 7, id: \.self) { _ in
                        VStack {
                            Infographics(selectedDate: $selectedGraphDate, data: filteredPredictions)
                            Spacer()
                            CongestionGraph(
                                data: filteredPredictions,
                                currentDate: mergedDate,
                                selectedDate: $selectedGraphDate,
                                selectedIndex: $selectedIndex
                            )
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: selectedIndex) { _, newIndex in
                    if let newDate = Calendar.current.date(byAdding: .day, value: newIndex, to: currentDate) {
                        selectedDate = newDate
                        selectedIndex = min(max(newIndex, 0), 14)
                    }
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
    mergedComponents.hour = max(hourComponent, 5) // 5시보다 작으면 5로 설정
    mergedComponents.minute = 0
    mergedComponents.second = 0

    return calendar.date(from: mergedComponents)!
}

#Preview {
    ContentView()
}
