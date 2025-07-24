//
//  ContentView.swift
//  MLTest
//
//  Created by 최희진 on 7/19/25.
//

import SwiftUI
import CoreML
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    let subwayModel = try? FinalModel(configuration: .init())
    
    @State private var outputArr: [Double] = []
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            if !outputArr.isEmpty{
                ForEach(outputArr, id: \.self){ output in
                    Text("인원수: \(output)")
                }
            } else{
                Text("출력값 없음")
            }
            
            Button("Generate Sample Data") {
                generateSampleData(context: context)
            }
        }
        .padding()
        .onAppear{
            predict()
        }
    }
    

    func predict() {
        do {
            let year: Int64 = 2025// TODO: 모델에 2025년 데이터 어떻게 넣어줄 것인지
            let month: Int64 = 2
            let day: Int64 = 1
            
            guard let weekday = weekdayFrom(year: year, month: month, day: day) else {
                print("Invalid date")
                return
            }

            for time in Timeline.allCases {
                let fetchDescriptor = FetchDescriptor<MockData>(
                    predicate: #Predicate {
                        $0.year == year &&
                        $0.month == month &&
                        $0.day == day
                    }
                )
                
                guard let mockData = try? context.fetch(fetchDescriptor).first(where: {
                    $0.timeline == time.rawValue
                }) else {
                    print("MockData 없음: \(year)-\(month)-\(day) \(time.rawValue)")
                    continue
                }
                print("MockData : \(mockData.timeline)")
                
                let input = createModelInput(
                    year: year,
                    month: month,
                    day: day,
                    weekday: weekday,
                    time: time,
                    mockData: mockData
                )
                
                let prediction = try subwayModel?.prediction(input: input)
                self.outputArr.append(prediction?.Passengers ?? 0.0)
                
                print(prediction ?? "예측 실패")
            }
            
        } catch {
            fatalError("Unexpected runtime error: \(error).")
        }
    }
    
    func weekdayFrom(year: Int64, month: Int64, day: Int64) -> Int? {
        var components = DateComponents()
        components.year = Int(year)
        components.month = Int(month)
        components.day = Int(day)
        let calendar = Calendar.current
        var weekday: Int? = nil
        
        if let date = calendar.date(from: components) {
            weekday = calendar.component(.weekday, from: date)
        } else {
            print("Invalid date")
        }
        return weekday
    }
    
    func createModelInput(year: Int64, month: Int64, day: Int64, weekday: Int, time: Timeline, mockData: MockData) -> FinalModelInput {
        let isHoliday = mockData.isHoliday == 1
        let isWeekday = weekday >= 1 && weekday <= 5//일~목

        let isLotteWorldOpen: Int64 = isWeekday && (10...21).contains(time.hour) ? 1 : 0//오전 10시 ~ 오후 9시
        let isLotteWorldMallOpen: Int64 = (weekday == 6 || weekday == 7 || isHoliday) && (10...22).contains(time.hour) ? 1 : 0 //오전 10시 ~ 오후 10시

        let morningCommute: Int64 = [.hour7, .hour8, .hour9].contains(time) ? 1 : 0
        let eveningCommute: Int64 = [.hour12, .hour13, .hour14].contains(time) ? 1 : 0
        let lateNight: Int64 = [.hour18, .hour19, .before6].contains(time) ? 1 : 0

        // 요일 인코딩
        let dayMonday: Int64 = weekday == 2 ? 1 : 0
        let dayTuesday: Int64 = weekday == 3 ? 1 : 0
        let dayWednesday: Int64 = weekday == 4 ? 1 : 0
        let dayThursday: Int64 = weekday == 5 ? 1 : 0
        let dayFriday: Int64 = weekday == 6 ? 1 : 0
        let daySaturday: Int64 = weekday == 7 ? 1 : 0
        let daySundayOrHoliday: Int64 = (weekday == 1 || isHoliday) ? 1 : 0

        return FinalModelInput(
            Year: year,
            Month: month,
            Day: day,
            Timeline: time.rawValue,
            Morning_Commute: morningCommute,
            Evening_Commute: eveningCommute,
            Late_Night: lateNight,
            Annual_seasonal_outiler: mockData.isAnnualOutlier,
            Lotte_World: isLotteWorldOpen,
            Lotte_World_Mall: isLotteWorldMallOpen,
            Day_Friday: dayFriday,
            Day_Thursday: dayThursday,
            Day_Wednesday: dayWednesday,
            Day_Monday: dayMonday,
            Day_Sunday: daySundayOrHoliday,
            Day_Saturday: daySaturday,
            Day_Tuesday: dayTuesday,
            Day_Holiday: isHoliday ? 1 : 0
        )
    }
    
    
    func generateSampleData(context: ModelContext) {
        for dayOffset in 1..<8 {
            for hour in 0..<20 {
                let isHoliday = (dayOffset == 1) ? 1 : 0 // 예시로 1월 1일만 공휴일 처리
                let isOutlier = Int.random(in: 0...1) // 랜덤 outlier 값

                let data = MockData(
                    year: Int64(2025),
                    month: Int64(2),
                    day: Int64(dayOffset),
                    timeline: Int64(hour),
                    isAnnualOutlier: Int64(isOutlier),
                    isHoliday: Int64(isHoliday)
                )
                context.insert(data)
            }
        }

        try? context.save()
        
        let data = try? context.fetch(FetchDescriptor<MockData>())
        print("data: \(data)")
    }
}

#Preview {
    ContentView()
}
