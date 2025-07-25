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
    
    @State private var predicts: [PredictModel] = []
    
    var body: some View {
        ScrollView{
            VStack {
                
                let data = predicts
                    .filter { $0.year == 2025 && $0.month == 7 && $0.day == 30 }
                    .sorted(by: { $0.timeline < $1.timeline })

                
                if !data.isEmpty {
                    GraphView(predicts: data)
                }
            
            }
            .padding()
            .onAppear{
                let savedData = fetchPredictData()
                if savedData.isEmpty {
                    loadCSVAndPredict()
                } else {//swiftData에 저장된 경우 불러오기
                    self.predicts = savedData.map {
                        PredictModel(year: $0.year, month: $0.month, day: $0.day, timeline: $0.timeline + 5, peopleCount: $0.peopleCount)
                    }.sorted { $0.day < $1.day }
                    print("스위프트 데이터에서 불러오기")
                }
            }
        }
    }
    
    func fetchPredictData() -> [PredictData] {
        let fetchDescriptor = FetchDescriptor<PredictData>()
        let data = (try? context.fetch(fetchDescriptor)) ?? []
        return data
    }

    func loadCSVAndPredict() {
            guard let path = Bundle.main.path(forResource: "exampleData", ofType: "csv") else {
                print("CSV 파일을 찾을 수 없습니다.")
                return
            }
            
            do {
                let csvString = try String(contentsOfFile: path, encoding: .utf8)
                let lines = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
                
                guard lines.count > 1 else { return } // 데이터 없음
                
                let rows = lines.dropFirst() // 헤더 제외
                
                for row in rows {
                    let columns = row.components(separatedBy: ",")
                    guard columns.count == 19 else {
                        print("잘못된 컬럼 수: \(columns.count)")
                        continue
                    }
                    
                    let cleanedColumns = columns.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                    guard let year = Int64(cleanedColumns[0]),
                          let month = Int64(cleanedColumns[1]),
                          let day = Int64(cleanedColumns[2]),
                          let timeline = Int64(cleanedColumns[3]),
                          let morningCommute = Int64(cleanedColumns[5]),
                          let eveningCommute = Int64(cleanedColumns[6]),
                          let lateNight = Int64(cleanedColumns[7]),
                          let annualOutlier = Int64(cleanedColumns[8]),
                          let lotteWorld = Int64(cleanedColumns[9]),
                          let lotteWorldMall = Int64(cleanedColumns[10]),
                          let dayFriday = Int64(cleanedColumns[11]),
                          let dayThursday = Int64(cleanedColumns[12]),
                          let dayWednesday = Int64(cleanedColumns[13]),
                          let dayMonday = Int64(cleanedColumns[14]),
                          let daySunday = Int64(cleanedColumns[15]),
                          let daySaturday = Int64(cleanedColumns[16]),
                          let dayTuesday = Int64(cleanedColumns[17]),
                          let dayHoliday = Int64(cleanedColumns[18]) else {
                        print("숫자 파싱 실패: \(cleanedColumns)")
                        continue
                    }
                    
                    let input = FinalModelInput(
                        Year: year,
                        Month: month,
                        Day: day,
                        Timeline: timeline,
                        Morning_Commute: morningCommute,
                        Evening_Commute: eveningCommute,
                        Late_Night: lateNight,
                        Annual_seasonal_outiler: annualOutlier,
                        Lotte_World: lotteWorld,
                        Lotte_World_Mall: lotteWorldMall,
                        Day_Friday: dayFriday,
                        Day_Thursday: dayThursday,
                        Day_Wednesday: dayWednesday,
                        Day_Monday: dayMonday,
                        Day_Sunday: daySunday,
                        Day_Saturday: daySaturday,
                        Day_Tuesday: dayTuesday,
                        Day_Holiday: dayHoliday
                    )
                    
                    do {
                        let prediction = try subwayModel?.prediction(input: input)
                        var passengers = Int64(prediction?.Passengers ?? 0.0)
                        
                        if passengers < 0 {passengers = 0}//음수인 경우 0으로 처리
                        
                        predicts.append(PredictModel(year: year, month: month, day: day, timeline: timeline + 5, peopleCount: passengers))
                        
                        //swift 데이터에 저장
                        let predictData = PredictData(year: year, month: month, day: day, timeline: timeline, peopleCount: passengers)
                        context.insert(predictData)
                        print("예측 결과 (\(year)-\(month)-\(day) 시간 \(timeline)): \(passengers)")
                    } catch {
                        print("예측 실패: \(error)")
                    }
                }
                try? context.save()
                print("swift 데이터에 저장 성공")
            } catch {
                print("CSV 로딩 실패: \(error)")
            }
        }
}

#Preview {
    ContentView()
}

