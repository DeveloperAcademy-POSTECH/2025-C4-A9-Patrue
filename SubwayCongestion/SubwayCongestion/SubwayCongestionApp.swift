//
//  SubwayCongestionApp.swift
//  SubwayCongestion
//
//  Created by Paidion on 7/18/25.
//

import SwiftData
import SwiftUI

@main
struct SubwayCongestionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(predictionContainer)
    }
}
