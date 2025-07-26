//
//  DateSelector.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/23/25.
//

import SwiftUI

struct DateSelector: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var selectedIndex: Int
    let range: Int = 15 // 15일치

    // selectedDate 기준 연속된 날짜 배열 반환
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
                ForEach(0 ..< data.count, id: \.self) { index in
                    Button(action: {
                        selectedIndex = index
                        selectedDate = data[index].date
                    }) {
                        VStack(alignment: index == 0 ? .trailing : index == data.count - 1 ? .leading : .center) {
                            Text(data[index].weekday)
                                .font(.headline)
                                .foregroundColor(selectedIndex == index ? .white : .primary)
                            Text("\(data[index].day)")
                                .font(.headline)
                                .foregroundColor(selectedIndex == index ? .white : .primary)
                        }
                        .frame(minWidth: 28)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 24)
                        .background(
                            Group {
                                if index == 0 {
                                    TopLeftCurvedShape()
                                        .fill(selectedIndex == 0 ? Color.green : .gray1)
                                } else if index == data.count - 1 {
                                    TopRightCurvedShape()
                                        .fill(selectedIndex == data.count - 1 ? Color.green : .gray1)
                                } else {
                                    selectedIndex == index ? Color.green : .gray1
                                }
                            }
                        )
                    }
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

func formattedWeekday(from date: Date) -> String {
    let fmt = DateFormatter()
    fmt.locale = Locale(identifier: "ko_KR")
    fmt.dateFormat = "E" // "일", "월", …
    return fmt.string(from: date)
}

struct TopLeftCurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + rect.width, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + rect.height),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.55, y: rect.minY))

        return path
    }
}

struct TopRightCurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 왼쪽 상단 시작 → 오른쪽 상단 직선 → 오른쪽 상단 곡선 → 오른쪽 하단 직선 → 왼쪽 하단 직선 → 닫기
        path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // 좌상단
        path.addLine(to: CGPoint(x: rect.maxX - rect.width, y: rect.minY)) // 우상단 곡선 시작점

        // 오른쪽 상단 모서리 곡선
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.85),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // 우하단
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // 좌하단

        return path
    }
}
