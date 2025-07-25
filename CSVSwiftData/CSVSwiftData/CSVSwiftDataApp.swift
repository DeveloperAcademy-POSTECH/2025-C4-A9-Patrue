//
//  CSVSwiftDataApp.swift
//  CSVSwiftData
//
//  Created by 서세린 on 7/24/25.
//

import SwiftUI
import SwiftData

@main
struct CSVSwiftDataApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([PredictionItem.self])
        let config = ModelConfiguration("MyPredictionDB")
        return try! ModelContainer(for: schema, configurations: [config])
    }()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
