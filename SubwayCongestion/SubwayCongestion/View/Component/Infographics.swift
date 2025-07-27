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
                // 인포그래픽, 설명 문구 로컬변수
                let info = congestionDescription(for: highlighted.passengers)

                // 시간대 표시
                Text(formattedHour(from: highlighted.asDate))
                    .font(.title2).bold()
                // 이미지
                Image(info.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                // 설명 문구
                Text(info.message)
                    .font(.body)
            }
            .padding()

        } else {
            Text("해당 시간대 데이터가 없어요")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
        }
    }

    // contentview에서 가져온 시간 변환 함수
    func formattedHour(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:00"
        return formatter.string(from: date)
    }

    // 이미지와 설명 문구 리턴
    private func congestionDescription(for passengers: Int) -> (imageName: String, message: String) {
        switch passengers {
        case 0 ..< 4000: return ("low", "운 좋으면 앉아갈 수 있는 정도")
        case 4000 ..< 7000: return ("medium", "사람들과 부딪히지 않을 정도")
        case 7000...: return ("high", "옆 사람과 어깨가 닿을 정도")
        default: return ("정보 없음", " ")
        }
    }
}
