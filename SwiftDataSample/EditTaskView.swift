//
//  DetailView.swift
//  SwiftDataSample
//
//  Created by Shingo Hiraya on 2023/06/14.
//

import SwiftUI

struct EditTaskView: View {
    @Bindable var task: Task

    var body: some View {
        TextField("やることを入力", text: $task.title)
            .padding()
    }
}
