//
//  SubwayCongestionApp.swift
//  SubwayCongestion
//
//  Created by Paidion on 7/18/25.
//

import SwiftUI

@main
struct SubwayCongestionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [PredictData.self])
        }
    }
}
