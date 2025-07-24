//
//  CongestionGuideSheet.swift
//  SubwayCongestionTest
//
//  Created by Paidion on 7/24/25.
//

import SwiftUI

struct CongestionGuideSheet: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("혼잡도 안내")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            Text("잠실역은 항상 혼잡하긴 해요")
                .font(.body)
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.35), .medium])
    }
}

#Preview {
    CongestionGuideSheet()
}
