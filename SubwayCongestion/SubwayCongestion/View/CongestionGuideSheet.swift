//
//  CongestionGuideSheet.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//

import SwiftUI

struct CongestionGuideSheet: View {
    @State private var currentDate: Date = .now
    @State private var selectedDate: Date = .now
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack {
            Text("정보")
                .font(.body)
                .fontWeight(.bold)

            VStack(spacing: 10) {
                CongestionInfoRow(number: 1, description: "달력에 스와이프하여\n날짜를 확인합니다.") {
                    DateSelector(currentDate: $currentDate, selectedDate: $selectedDate, selectedIndex: $selectedIndex)
                }

                CongestionInfoRow(number: 2, description: "그래프를 드래그하여 시간을 선택합니다.") {
                    Image("CongestionInfo2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

                CongestionInfoRow(number: 3, description: "선택한 날짜 및 시간의 혼잡도를 확인합니다.") {
                    Image("CongestionInfo3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

                // 기준 & 근거 정보
                HStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("기준")
                                .font(.system(size: 22, weight: .bold))
                            Spacer()
                            Text("여유: 40% 미만\n보통: 40% ~ 70%\n혼잡: 70% 초과")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .padding()
                    .background(.gray2, in: RoundedRectangle(cornerRadius: 16))

                    HStack {
                        VStack(alignment: .leading) {
                            Text("근거")
                                .font(.system(size: 22, weight: .bold))
                            Spacer()
                            Text("출퇴근, 계절, 요일,\n근처 이벤트 등 다양한\n정보를 통한 Ai 추론")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .padding()
                    .background(.gray2, in: RoundedRectangle(cornerRadius: 16))
                }
                .frame(height: 180)
            }
        }
        .presentationDragIndicator(.visible)
        .padding()
    }
}

#Preview {
    CongestionGuideSheet()
}
