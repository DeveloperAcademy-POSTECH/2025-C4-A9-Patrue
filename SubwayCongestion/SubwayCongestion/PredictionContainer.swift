//
//  PredictionContainer
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//

import Foundation
import SwiftData

@MainActor
var predictionContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Prediction.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        )
        let modelContext = container.mainContext

        let regressionModel = try? Final(configuration: .init())

        if try modelContext.fetch(FetchDescriptor<Prediction>()).isEmpty {
            guard let path = Bundle.main.path(forResource: "final_input", ofType: "csv") else {
                print("CSV 파일을 찾을 수 없습니다.")
                return container
            }

            let csvString = try String(contentsOfFile: path, encoding: .utf8)
            let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
            let rows = lines.dropFirst()

            for row in rows {
                let columns = row.components(separatedBy: ",")
                if let month = Int(columns[0]),
                   let day = Int(columns[1]),
                   let timeline = Int(columns[2]),
                   let lotteVisit = Int(columns[3]),
                   let dayOfWeek = Int(columns[4]),
                   let holiday = Int(columns[5]),
                   let specialDay = Int(columns[6]),
                   let isWeekend = Int(columns[7])
                {
                    // 여기에 CoreML 예측값 적용
                    let predictedPassengers: Int
                    do {
                        let prediction = try regressionModel?.prediction(
                            Month: Int64(month),
                            Day: Int64(day),
                            Timeline: Int64(timeline),
                            Lotte_Visit: Int64(lotteVisit),
                            Day_of_Week: Int64(dayOfWeek),
                            Holiday: Int64(holiday),
                            Special_Day: Int64(specialDay),
                            is_weekend: Int64(isWeekend)
                        )
                        predictedPassengers = Int((prediction?.Passengers ?? 0).rounded())
                    } catch {
                        print("예측 실패: \(error)")
                        continue
                    }

                    let newPrediction = Prediction(year: 2025, month: month, day: day, timeline: timeline + 5, passengers: predictedPassengers)
                    container.mainContext.insert(newPrediction)
                }
            }
        } else {
            print("예측 데이터가 이미 SwiftData에 저장되어 있습니다!")
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

extension Calendar {
    static func date(bySettingHour hour: Int, of date: Date) -> Date? {
        Calendar.current.date(
            bySettingHour: hour,
            minute: 0,
            second: 0,
            of: date
        )
    }
}
