//
//  CustomStationTitle.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//

import SwiftUI

struct CustomStationTitle: View {
    let stoke: CGFloat = 6
    let radius: CGFloat = 18
    let offset: CGFloat = 24.5

    var body: some View {
        ZStack {
            // 배경 및 테두리
            RoundedRectangle(cornerRadius: radius)
                .stroke(Color.green, lineWidth: stoke)
                .background(
                    RoundedRectangle(cornerRadius: radius)
                        .fill(Color.white)
                )
                .frame(height: 36)
            // 좌우 라인 연출 (이미지 대신 SwiftUI 도형 사용 예시)
            HStack {
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 26, height: stoke)
                    .offset(x: -offset)
                Spacer()
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 26, height: stoke)
                    .offset(x: offset)
            }
            // 잠실역 텍스트
            Text("잠실역")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
        }
        .fixedSize()
    }
}

#Preview {
    CustomStationTitle()
}
