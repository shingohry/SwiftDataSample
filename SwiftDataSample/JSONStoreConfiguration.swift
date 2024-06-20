//
//  JSONStoreConfiguration.swift
//  SwiftDataSample
//
//  Created by Shingo Hiraya on 2024/06/20.
//

import Foundation
import SwiftData

final class JSONStoreConfiguration: DataStoreConfiguration {
    // カスタムのストアを指定
    typealias StoreType = JSONStore

    // DataStoreConfigurationプロトコルに定義されたプロパティ
    var name: String
    var schema: Schema?

    // これはオリジナル
    var fileURL: URL

    init(
        name: String,
        schema: Schema? = nil,
        fileURL: URL
    ) {
        self.name = name
        self.schema = schema
        self.fileURL = fileURL
    }

    // DataStoreConfigurationはHashableにも準拠しているのでそちらも実装
    static func == (lhs: JSONStoreConfiguration, rhs: JSONStoreConfiguration) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
