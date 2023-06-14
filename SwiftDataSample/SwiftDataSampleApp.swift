//
//  SwiftDataSampleApp.swift
//  SwiftDataSample
//
//  Created by Shingo Hiraya on 2023/06/14.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}
