//
//  ChartTest.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//

import Charts
import SwiftUI

struct ChartTestView: View {
    var data: [Prediction] // [year, month, day, timeline, passengers]
    @Binding var selectedDate: Date

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
                }
            }
            .chartYScale(range: .plotDimension(padding: 2))
            .chartYAxis {
                AxisMarks(
                    values: [0, 5000, 10000, 15000, 20000]
                ) {
                    AxisGridLine()
                }
            }
        }
        .padding()
    }

    func descriptionForCongestion(_ passengers: Int) -> String {
        switch passengers {
        case 0 ... 5000: return "Low"
        case 5001 ... 10000: return "Moderate"
        case 10001 ... 15000: return "High"
        default: return "Extreme"
        }
    }
}
