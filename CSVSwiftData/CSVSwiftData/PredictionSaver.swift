//
//  PredictionSaver.swift
//  CSVSwiftData
//
//  Created by 서세린 on 7/24/25.
//

import Foundation
import CoreML
import SwiftData

func predictAndStoreIfNeeded(model: Testmodel, context: ModelContext) {
    // 이미 저장된 데이터가 있다면 중복 저장 방지
    let fetchDescriptor = FetchDescriptor<PredictionItem>()
    if let count = try? context.fetchCount(fetchDescriptor), count > 0 {
        print("🔁 이미 예측 데이터가 저장되어 있습니다.")
        return
    }

    // CSV에서 데이터 불러오기
    guard let path = Bundle.main.path(forResource: "future_august_2025_input", ofType: "csv") else {
        print("❌ CSV 파일을 찾을 수 없습니다.")
        return
    }

    do {
        let csv = try String(contentsOfFile: path, encoding: .utf8)
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }
        let rows = lines.dropFirst() // 헤더 제외

        for row in rows {
            let columns = row.components(separatedBy: ",")
            guard columns.count == 5 else { continue }

            if let year = Int(columns[0]),
               let month = Int(columns[1]),
               let day = Int(columns[2]),
               let weekday = Int(columns[4]) {

                let timeSlot = columns[3]

                do {
                    let result = try model.prediction(
                        year: Int64(year),
                        month: Int64(month),
                        day: Int64(day),
                        time_slot: timeSlot,
                        weekday: Int64(weekday)
                    )

                    let count = max(Int(result.people_count), 0) // 음수 방지
                    let item = PredictionItem(year: year, month: month, day: day, timeSlot: timeSlot, peopleCount: count)
                    context.insert(item)

                } catch {
                    print("⚠️ 예측 실패: \(error)")
                }
            }
        }

        try context.save()
        print("✅ 예측 결과를 성공적으로 저장했습니다.")

    } catch {
        print("❌ CSV 읽기 실패: \(error)")
    }
}

