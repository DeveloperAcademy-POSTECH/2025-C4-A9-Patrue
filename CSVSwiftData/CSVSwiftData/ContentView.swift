//
//  ContentView.swift
//  CSVSwiftData
//
//  Created by 서세린 on 7/24/25.
//

import SwiftUI
import SwiftData
import CoreML

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var currentDate = Date() //버튼
    @State private var selectedDate = Date() //버튼
    
    var body: some View {
        //        VStack {
        //            PredictionResultView(year: 2025, month: 8, day: 2)
        //        }
        NavigationStack{
            VStack {
                DateSelector(currentDate: $currentDate, selectedDate: $selectedDate)
                
                Divider()
                
                Spacer()
                
                let calendar = Calendar.current
                let year = calendar.component(.year, from: selectedDate)
                let month = calendar.component(.month, from: selectedDate)
                let day = calendar.component(.day, from: selectedDate)
                
                PredictionChartView(year: year, month: month, day: day) // ✅ 차트로 대체
                    .padding(.top)
                
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomStationTitle()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
    //                    showGuideSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .accessibilityLabel("이용 안내")
                }
            }
            .onAppear {
                if let model = try? Testmodel(configuration: MLModelConfiguration()) {
                    predictAndStoreIfNeeded(model: model, context: context)//앱 시작점에서 함수 불러오기
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
