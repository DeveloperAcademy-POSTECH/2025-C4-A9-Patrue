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
    @State private var selectedIndex: Int = 0
    
    @State private var timer: Timer? = nil //타이머 변수 추가

    var filteredPredictions: [Prediction] {
        let calendar = Calendar.current
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
                    ForEach(0..<15, id: \.self) { offset in
                        VStack {
                            Infographics(selectedDate: $selectedGraphDate, data: filteredPredictions)
                            Spacer()
                            CongestionGraph(
                                data: filteredPredictions,
                                currentDate: mergedDate,
                                selectedDate: $selectedGraphDate
                            )
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: selectedIndex) {  _, newIndex in
                    if let newDate = Calendar.current.date(byAdding: .day, value: newIndex, to: currentDate) {
                        selectedDate = newDate
                        selectedIndex = min(max(newIndex, 0), 14)
                        print(selectedIndex, selectedDate)
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
            .onAppear {
                if timer == nil {
                    scheduleHourlyUpdate()
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    //앱 진입시 정각까지 남은 시간을 재는 함수.
    private func scheduleHourlyUpdate() {
        let now = Date()
        let calendar = Calendar.current
        
        if let nextHour = calendar.date(bySettingHour: calendar.component(.hour, from: now) + 1,
                                        minute: 0,
                                        second: 0,
                                        of: now) {
            
            let interval = nextHour.timeIntervalSince(now)
            print("⏱ 정각까지 \(Int(interval))초 남음")
            
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                currentDate = Date()
                print("🕐 정각 도달! currentDate 갱신됨")
                
                timer?.invalidate() // 혹시 모르니 안전하게
                timer = nil          // 타이머 초기화
                scheduleHourlyUpdate() // 다음 정각 예약
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

