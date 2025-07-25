//
//  DateSelector.swift
//  CSVSwiftData
//
//  Created by 서세린 on 7/25/25.
//

import SwiftUI

struct DateSelector: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date

    @State private var selectedIndex: Int = 0
    private let range: Int = 15 // 총 15일치 표시

    // selectedDate 기준으로 날짜 배열 생성
    var data: [(weekday: String, day: Int, date: Date)] {
        (0 ..< range).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: currentDate)!
            let weekday = formattedWeekday(from: date)
            let day = Calendar.current.component(.day, from: date)
            return (weekday, day, date)
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(data.indices, id: \.self) { index in
                    let item = data[index]
                    Button {
                        selectedIndex = index
                        selectedDate = item.date
                    } label: {
                        DateSelectorButtonView(
                            weekday: item.weekday,
                            day: item.day,
                            isSelected: selectedIndex == index,
                            isFirst: index == 0,
                            isLast: index == data.count - 1
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - 하위 뷰: 버튼 형태 분리

struct DateSelectorButtonView: View {
    let weekday: String
    let day: Int
    let isSelected: Bool
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        VStack {
            Text(weekday)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
            Text("\(day)")
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(minWidth: 28)
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
        .background(
            Group {
                if isFirst {
                    TopLeftCurvedShape()
                        .fill(isSelected ? Color.green : Color(hex: "E0E0E0"))
                } else if isLast {
                    TopRightCurvedShape()
                        .fill(isSelected ? Color.green : Color(hex: "E0E0E0"))
                } else {
                    isSelected ? Color.green : Color(hex: "E0E0E0")
                }
            }
        )
        .cornerRadius(12)
    }
}

// MARK: - Shape: 양쪽 곡선 배경

struct TopLeftCurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + rect.width, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + rect.height),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.55, y: rect.minY))

        return path
    }
}

struct TopRightCurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.85),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}

// MARK: - 요일 포맷 함수

func formattedWeekday(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "E" // "월", "화", "수" 등
    return formatter.string(from: date)
}
