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

        let regressionModel = try? Basic(configuration: .init())

        if try modelContext.fetch(FetchDescriptor<Prediction>()).isEmpty {
            guard let path = Bundle.main.path(forResource: "future_input", ofType: "csv") else {
                print("CSV 파일을 찾을 수 없습니다.")
                return container
            }

            let csvString = try String(contentsOfFile: path, encoding: .utf8)
            let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
            let rows = lines.dropFirst()
//            var count = 0

            for row in rows {
                let columns = row.components(separatedBy: ",")
//                guard columns.count >= 4 else { continue }
                if let month = Int(columns[1]),
                   let day = Int(columns[2]),
                   let timeline = Int(columns[3])
                {
                    // 여기에 CoreML 예측값 적용
                    let predictedPassengers: Int
                    do {
                        let prediction = try regressionModel?.prediction(
                            month: Int64(month),
                            day: Int64(day),
                            timeline: Int64(timeline) + 5,
                            morning_commute: Int64(timeline) >= 3 && Int64(timeline) <= 5 ? 1 : 0,
                            evening_commute: Int64(timeline) >= 15 && Int64(timeline) <= 7 ? 1 : 0,
                            late_night: Int64(timeline) >= 18 ? 1 : 0
                        )
                        predictedPassengers = Int((prediction?.passengers ?? 0).rounded())
                    } catch {
                        print("예측 실패: \(error)")
                        continue
                    }

                    // SwiftData에 저장
//                    let components = DateComponents(year: 2025, month: month, day: day, hour: timeline + 5)
//                    let date = Calendar.current.date(from: components)!
                    let newPrediction = Prediction(year: 2025, month: month, day: day, timeline: timeline + 5, passengers: predictedPassengers)
                    container.mainContext.insert(newPrediction)
//                    count += 1
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
