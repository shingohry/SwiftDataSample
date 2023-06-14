//
//  AddTaskView.swift
//  SwiftDataSample
//
//  Created by Shingo Hiraya on 2023/06/14.
//

import SwiftUI

struct AddTaskView: View {
    @State var task = Task(title: "")
    @Environment(\.modelContext) private var modelContext
    @Binding var showingAddTaskView: Bool

    var body: some View {
        TextField("やることを入力", text: $task.title)
            .padding()
            .navigationBarItems(
                trailing: Button(action: {
                    modelContext.insert(object: task)
                    showingAddTaskView = false
                }) {
                    Text("保存")
                }
            )
    }
}
