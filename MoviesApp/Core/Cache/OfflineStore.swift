//
//  OfflineStore.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 20.4.26.
//

import Foundation

/// Actor-based JSON file cache stored in the Caches directory.
/// Each entry is a separate JSON file keyed by a string identifier.
actor OfflineStore {

    private let directory: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.directory = caches.appendingPathComponent("OfflineStore", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    // MARK: - Public API

    func save<T: Encodable>(_ value: T, forKey key: String) {
        let url = fileURL(for: key)
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("[OfflineStore] Failed to save \(key): \(error)")
        }
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        let url = fileURL(for: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Private

    private func fileURL(for key: String) -> URL {
        directory.appendingPathComponent("\(key).json")
    }
}
