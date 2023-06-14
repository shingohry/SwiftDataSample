//
//  ContentView.swift
//  SwiftDataSample
//
//  Created by Shingo Hiraya on 2023/06/14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var tasks: [Task]
    @State private var showingAddTaskView = false
    @State private var showingEditTaskView = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                    HStack {
                        Button {
                            task.finished.toggle()
                        } label: {
                            Image(systemName: task.finished ? "checkmark" : "square")
                                .frame(width: 24)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(task.title) {
                            EditTaskView(task: task)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationDestination(isPresented: $showingAddTaskView) {
                AddTaskView(showingAddTaskView: $showingAddTaskView)
            }
            .navigationBarItems(
                trailing: Button(action: {
                    showingAddTaskView = true
                }) {
                    Text("追加")
                }
            )
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}

#Preview {
    // https://developer.apple.com/forums/thread/731320
    MainActor.assumeIsolated {
        ContentView()
            .modelContainer(previewContainer)
    }
}
//#Preview {
//    ContentView()
//        .modelContainer(previewContainer)
//}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Task.self, ModelConfiguration(inMemory: true)
        )
        let sampleTasks = [
            Task(title: "テストケースを作成する"),
            Task(title: "データベースの設計を検討する"),
            Task(title: "コードレビューを行う"),
            Task(title: "バグ修正を行う"),
            Task(title: "ドキュメントを更新する")]
        for task in sampleTasks {
            container.mainContext.insert(object: task)
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
