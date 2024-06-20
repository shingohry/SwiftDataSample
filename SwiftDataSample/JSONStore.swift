//
//  JSONStore.swift
//  SwiftDataSample
//
//  Created by Shingo Hiraya on 2024/06/20.
//

import Foundation
import SwiftData

/*
 There are three key parts to a store:
 a configuration to describe the store,
 snapshots to communicate model values with the model context,
 and a store implementation that the ModelContainer can manage.

 Each of these parts conform to three different protocols:
 - Configuration: DataStoreConfiguration
 - Communication: DataStoreSnapshot
 - Implementation: DataStore

 The default store in SwiftData provides its own implementation of these types:
 - ModelConfiguration
 - DefaultSnapshot
 - DefaultStore
 */

final class JSONStore: DataStore {
    // カスタムのConfigurationを指定
    typealias Configuration = JSONStoreConfiguration
    // デフォルト実装のSnapshot
    typealias Snapshot = DefaultSnapshot

    // DataStoreプロトコルに定義されたプロパティ
    var configuration: JSONStoreConfiguration
    var name: String
    var schema: Schema
    var identifier: String

    init(
        _ configuration: JSONStoreConfiguration,
        migrationPlan: (any SchemaMigrationPlan.Type)?
    ) throws {
        self.configuration = configuration
        self.name = configuration.name
        self.schema = configuration.schema!
        self.identifier = configuration.fileURL.lastPathComponent
    }

    // 実装必須なのは fetchとsave
    // (1) Now I can begin implementing the two required methods for a DataStore to be usable with the ModelContext: fetch and save.
    // When the ModelContext sends a DataStoreFetchRequest, I need to load the data that's in the store, and instantiate a DataStoreFetchResult.

    func save(_ request: DataStoreSaveChangesRequest<DefaultSnapshot>) throws -> DataStoreSaveChangesResult<DefaultSnapshot> {
        // (5) With fetch implemented,  I can implement save to write the snapshots in to the JSON file.
        // When implementing save, I want to consider and handle 3 types of changes: insertions, updates, and deletions.

        // (6) Before I begin processing the incoming snapshots in the save request, I first have to read in the current contents of the file, which I handle in a separate method that I defined called read.
        // I'll organize all of the snapshots into a dictionary keyed by their persistent identifier,
        // which will be my working copy for the new JSON file that will be written to disk at the end.
        var remappedIdentifiers = [PersistentIdentifier: PersistentIdentifier]()
        var serializedSnapshots = try self.read()

        // (7) Then I process the snapshots of the inserted models within the save request.
        // This involves assigning and remapping Identifiers for each inserted snapshot.
        for snapshot in request.inserted {
            // (8) Let me examine this in a little more detail.
            // Recall that when models are inserted into the store, each models a temporary identifier that's not associated with any store.
            // For each inserted snapshot here, I create a new  permanent persistent identifier.
            // I then create a copy of the snapshot that uses the new persistent identifier.
            // This new persistent identifier is mapped to the tempotrary one in the remappedIdentifiers dictionary to return to the ModelContext later in the save result.
            let permanentIdentifier = try PersistentIdentifier.identifier(
                for: identifier,
                entityName: snapshot.persistentIdentifier.entityName,
                primaryKey: UUID()
            )
            let permanentSnapshot = snapshot.copy(persistentIdentifier: permanentIdentifier)

            // (9) Finally, l add the inserted snapshots to the ones initially loaded from the file.
            serializedSnapshots[permanentIdentifier] = permanentSnapshot
            remappedIdentifiers[snapshot.persistentIdentifier] = permanentIdentifier
        }

        // (10) After processing the inserted snapshots, I process the updates by replacing the snapshots from the file with the ones in the save request.
        for snapshot in request.updated {
            serializedSnapshots[snapshot.persistentIdentifier] = snapshot
        }

        // (11) And finally, remove the deleted snapshots from those loaded from the file.
        for snapshot in request.deleted {
            serializedSnapshots[snapshot.persistentIdentifier] = nil
        }

        try self.write(serializedSnapshots)

        // (12) Finally, I return a DataStoreSaveChangesResult with the results of the save.
        // The DataStoreSaveChangesResult includes the remapped persistentldentifiers for the context to update.
        return DataStoreSaveChangesResult<DefaultSnapshot>(
            for: self.identifier,
            remappedPersistentIdentifiers: remappedIdentifiers,
            deletedIdentifiers: request.deleted.map({ $0.persistentIdentifier })
        )
    }

    func fetch<T>(_ request: DataStoreFetchRequest<T>) throws -> DataStoreFetchResult<T, DefaultSnapshot> where T : PersistentModel {
        // (4) Currently, this implementation doesn't process the predicate or sort comparators that are on a FetchDescriptor.
        // The translation of a Predicate or sort comparator can be an involved process, and I can instead use the ModelContext to perform this work for me.
        //
        // To do this, throw the preferInMemoryFilter and preferInMemorySort errors when the request contains, a predicate or sort descriptor.
        // This works great for my case, because this is a small data set that can be loaded into memory.
        // I now have a fully functional  fetch implementation that can support queries and sorting.
        if request.descriptor.predicate != nil {
            throw DataStoreError.preferInMemoryFilter
        } else if request.descriptor.sortBy.count > 0 {
            throw DataStoreError.preferInMemorySort
        }

        let objs = try self.read()
        let snapshots = objs.values.map({ $0 })

        // (3) Then, I'll instantiate and return a DataStoreFetchResult with the snapshots from the file.
        return DataStoreFetchResult(
            descriptor: request.descriptor,
            fetchedSnapshots: snapshots,
            relatedSnapshots: objs
        )
    }

    private func read() throws -> [PersistentIdentifier: DefaultSnapshot] {
        if FileManager.default.fileExists(atPath: configuration.fileURL.path(percentEncoded: false)) {
            // (2) Because the DefaultSnapshot is codable, I can use the JSONDecoder to load the data for the store from the file URL provided by the configuration.
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let snapshots = try decoder.decode(
                [DefaultSnapshot].self,
                from: try Data(contentsOf: configuration.fileURL)
            )
            var result = [PersistentIdentifier: DefaultSnapshot]()
            snapshots.forEach { s in
                result[s.persistentIdentifier] = s
            }
            return result
        } else {
            return [:]
        }
    }

    private func write(_ snapshots: [PersistentIdentifier: DefaultSnapshot]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(snapshots.values.map({ $0 }))
        try jsonData.write(to: configuration.fileURL)
    }
}
