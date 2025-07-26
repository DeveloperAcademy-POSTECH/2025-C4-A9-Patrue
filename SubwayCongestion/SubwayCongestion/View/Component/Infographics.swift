//
//  Infographics.swift
//  SubwayCongestion
//
//  Created by 서세린 on 7/26/25.
//


import SwiftUI

struct Infographics: View {
    @Binding var selectedDate: Date
    let data: [Prediction]
    
    var body: some View {
        if let highlighted = data.first(where: {
            Calendar.current.isDate($0.asDate, equalTo: selectedDate, toGranularity: .hour)
        }) {
            VStack(spacing: 8) {
                // ✅ 텍스트용 설명 함수로 변경
                Text(congestionDescription(for: highlighted.passengers))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding()
        } else {
            Text("해당 시간대 데이터가 없어요")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    // ✅ 텍스트로 리턴
    private func congestionDescription(for passengers: Int) -> String {
        switch passengers {
        case 0..<4000: return "여유"
        case 4000..<7000: return "보통"
        case 7000...: return "혼잡"
        default: return "정보 없음"
        }
    }
}
