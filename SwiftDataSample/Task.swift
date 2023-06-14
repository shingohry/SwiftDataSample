//
//  ToDo.swift
//  SwiftDataSample
//
//  Created by Shingo Hiraya on 2023/06/14.
//

import Foundation
import SwiftData

@Model
final class Task {
    var title: String
    var finished = false

    init(title: String) {
        self.title = title
    }
}
