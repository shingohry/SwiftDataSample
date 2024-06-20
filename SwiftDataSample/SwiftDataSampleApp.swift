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
    var container: ModelContainer = {
        let modelContainer: ModelContainer
        do {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data.json")
            print("fileURL:", fileURL)
            let configuration = JSONStoreConfiguration(
                name: "",
                schema: Schema([Task.self]),
                fileURL: fileURL
            )
            modelContainer = try ModelContainer(
                for: Task.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        return modelContainer
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
//        .modelContainer(for: Task.self)
    }
}
