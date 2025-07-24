//
//  ContentView.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/6/25.
//

import Charts
import CoreML
import SwiftUI

struct ContentView: View {
    let model = try? Basic(configuration: .init())

    @State private var currentDate: Date = .now
    @State private var selectedDate: Date = .now
    @State private var predictions: [Prediction] = []
    @State private var showGuideSheet: Bool = false

    var filteredPredictions: [Prediction] {
        let calendar = Calendar.current
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let selectedDay = calendar.component(.day, from: selectedDate)

        return predictions.filter { item in
            item.month == selectedMonth && item.day == selectedDay
        }
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let allTimelines = Array(0 ... 23)

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
                    VStack {
                        Text(formattedHour(currentDate))
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("선택된 날짜 및 시간")
                        Text("\(selectedDate)")
                    }
                    // 2. 혼잡도 차트
                    Text("선택한 날짜 혼잡도 정보들")
                    List(filteredPredictions) { item in
                        Text("Month: \(item.month),Day: \(item.day), Timeline: \(item.timeline), Passengers: \(item.passengers)")
                    }
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
                loadCSVAndPredict()
            }
        }
    }

    func loadCSVAndPredict() {
        guard let path = Bundle.main.path(forResource: "future_input", ofType: "csv") else {
            print("CSV 파일을 찾을 수 없습니다.")
            return
        }

        do {
            let csvString = try String(contentsOfFile: path, encoding: .utf8)
            let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
            let rows = lines.dropFirst()
            var tempResults: [Prediction] = []
            for row in rows {
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 4 else { continue }
                if let month = Int(columns[1]),
                   let day = Int(columns[2]),
                   let timeline = Int(columns[3])
                {
                    do {
                        let prediction = try model?.prediction(
                            month: Int64(month),
                            day: Int64(day),
                            timeline: Int64(timeline),
                            morning_commute: Int64(timeline) >= 3 && Int64(timeline) <= 5 ? 1 : 0,
                            evening_commute: Int64(timeline) >= 15 && Int64(timeline) <= 7 ? 1 : 0,
                            late_night: Int64(timeline) >= 18 ? 1 : 0
                        )
                        let passengers = Int((prediction?.passengers ?? 0).rounded())

                        tempResults.append(
                            Prediction(month: month, day: day, timeline: timeline, passengers: passengers)
                        )
                    } catch {
                        print("예측 실패: \(error)")
                    }
                }
            }
            DispatchQueue.main.async {
                predictions = tempResults
            }
        } catch {
            print("CSV 로딩 실패: \(error)")
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

struct Prediction: Identifiable, Hashable {
    let id = UUID()
    let month: Int
    let day: Int
    let timeline: Int
    let passengers: Int
}

#Preview {
    ContentView()
}
