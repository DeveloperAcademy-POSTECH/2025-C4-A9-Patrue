//
//  CongestionInfoRow.swift
//  SubwayCongestion
//
//  Created by Paidion on 7/26/25.
//

import SwiftUI

struct CongestionInfoRow<Content: View>: View {
    let number: Int
    let description: String
    @ViewBuilder var content: Content

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(number)")
                    .font(.system(size: 22, weight: .bold))

                Spacer()
                Text(description)
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding()
            Spacer()
            content
        }
        .background(Color.gray2, in: RoundedRectangle(cornerRadius: 16))
        .frame(height: 150)
    }
}
