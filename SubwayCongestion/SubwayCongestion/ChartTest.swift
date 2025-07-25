//
//  ChartTestView.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//


import Charts
import SwiftUI

struct ChartTestView: View {
    // [month, day, timeline]
    var data: [Prediction]

    var body: some View {
        VStack(alignment: .leading) {
            Chart {
                ForEach(data, id: \.id) { dataPoint in
                    LineMark(
                        x: .value("Time of day", dataPoint.asDate),
                        y: .value("Passengers", dataPoint.passengers)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .alignsMarkStylesWithPlotArea()

                    PointMark(
                        x: .value("Time of day", dataPoint.asDate),
                        y: .value("Passengers", dataPoint.passengers)
                    )
                    .symbolSize(CGSize(width: 18, height: 18))
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)

                    PointMark(
                        x: .value("Time of day", dataPoint.asDate),
                        y: .value("Passengers", dataPoint.passengers)
                    )
                    .symbolSize(CGSize(width: 8, height: 8))
                    .foregroundStyle(.white)
                    //                    .accessibilityLabel("Now")
                }

                //                if let dataPoint = closestDataPoint(for: currentDate) {
                //                    if let firstDataPoint = currentUVData.first {
                //                        RectangleMark(
                //                            xStart: .value("", firstDataPoint.date),
                //                            xEnd: .value("", dataPoint.date)
                //                        )
                //                        .foregroundStyle(.thickMaterial)
                //                        .opacity(1)
                //                        .accessibilityHidden(true)
                //                        .mask {
                //                            ForEach(currentUVData, id: \.date) { dataPoint in
                //                                AreaMark(
                //                                    x: .value("Time of day", dataPoint.date),
                //                                    y: .value("UV index", dataPoint.uv),
                //                                    series: .value("", "mask"),
                //                                    stacking: .unstacked
                //                                )
                //                                .interpolationMethod(.cardinal)
                //
                //                                LineMark(
                //                                    x: .value("Time of day", dataPoint.date),
                //                                    y: .value("UV index", dataPoint.uv),
                //                                    series: .value("", "mask")
                //                                )
                //                                .interpolationMethod(.cardinal)
                //                                .lineStyle(StrokeStyle(lineWidth: 4))
                //                            }
                //                        }
                //                    }
                //
                //                    RuleMark(x: .value("Now", dataPoint.date))
                //                        .foregroundStyle(Color.secondary)
                //                        .accessibilityHidden(true)
                //
                //                    PointMark(
                //                        x: .value("Time of day", dataPoint.date),
                //                        y: .value("UV index", dataPoint.uv)
                //                    )
                //                    .symbolSize(CGSize(width: 16, height: 16))
                //                    .foregroundStyle(.regularMaterial)
                //                    .accessibilityHidden(true)
                //
                //                    PointMark(
                //                        x: .value("Time of day", dataPoint.date),
                //                        y: .value("UV index", dataPoint.uv)
                //                    )
                //                    .symbolSize(CGSize(width: 6, height: 6))
                //                    .foregroundStyle(Color.primary)
                //                    .accessibilityLabel("Now")
                //                }
            }

//            .chartXAxis {
//                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
//                    if let date = value.as(Date.self) {
//                        let hour = Calendar.current.component(.hour, from: date)
//                        // 오전 6시, 오후 12시 (12), 오후 6시 (18), 자정 (0)에만 축을 표시
//                        if hour == 6 || hour == 12 || hour == 18 || hour == 0 {
//                            AxisGridLine()
//                            AxisTick()
//                            AxisValueLabel(format: .dateTime.hour())
//                        }
//                    }
//                }
//            }

            .chartYScale(range: .plotDimension(padding: 2))
            .chartYAxis {
                AxisMarks(
                    values: [0, 5000, 10000, 15000, 20000]
                ) {
                    AxisGridLine()
                }

                //                AxisMarks(
                //                    format: .number,
                //                    preset: .aligned,
                //                    position: .leading,
                //                    values: Array(0 ... 25000)
                //                )
                //
                //                AxisMarks(
                //                    preset: .inset,
                //                    position: .trailing,
                //                    values: [0, 500, 1000, 1500, 2000]
                //                ) { value in
                //                    print("value: \(value)")
                //                    AxisValueLabel(
                //                        //                        descriptionForCongestion(value.as(Double.self)!)
                //                        descriptionForCongestion(value)
                //                    )
                //                }
            }
        }
        .padding()
        .border(Color.blue)
        .onAppear {
            print("\(data[19].month)-\(data[19].day)-\(data[19].timeline)-\(data[19].passengers)")
        }
    }

    //    func closestDataPoint(for date: Date) -> (date: Date, passengers: Int)? {
    //        data.sorted { first, second in
    //            abs(date.timeIntervalSince(first.date)) < abs(date.timeIntervalSince(second.date))
    //        }.first
    //    }

    func descriptionForCongestion(_ passengers: Int) -> String {
        switch passengers {
        case 0 ... 5000: return "Low"
        case 5001 ... 10000: return "Moderate"
        case 10001 ... 15000: return "High"
        default: return "Extreme"
        }
    }
}

// #Preview {
//    ChartTestView()
// }
