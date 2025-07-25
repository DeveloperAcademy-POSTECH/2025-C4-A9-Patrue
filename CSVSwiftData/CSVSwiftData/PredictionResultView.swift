//
//  PredictionResultView.swift
//  CSVSwiftData
//
//  Created by 서세린 on 7/24/25.
//
//
//import SwiftUI
//import SwiftData
//
//struct PredictionResultView: View {
//    @Query var predictions: [PredictionItem] //저장된 데이터 읽어오기
//    
//    //조건 만들기
//    init(year: Int, month: Int, day: Int) {
//        _predictions = Query(filter: #Predicate<PredictionItem> {
//            $0.year == year && $0.month == month && $0.day == day
//        }, sort: \.timeSlot)
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("혼잡도 예측 결과")
//                .font(.title2)
//                .padding(.bottom)
//            
//            // ✅ 차트 추가 (위)
//            PredictionChartView(predictions: predictions)
//                .padding(.bottom)
//            
//            ForEach(predictions) { item in
//                HStack {
//                    Text(item.timeSlot)
//                        .frame(width: 100, alignment: .leading)
//                    Spacer()
//                    Text("\(item.peopleCount)명")
//                }
//            }
//        }
//        .padding()
//    }
//}
//
////#Preview {
////    PredictionResultView(year: <#Int#>, month: <#Int#>, day: <#Int#>)
////}
