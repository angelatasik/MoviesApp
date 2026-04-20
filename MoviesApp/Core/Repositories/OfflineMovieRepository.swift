//
//  OfflineMovieRepository.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 20.4.26.
//

import Foundation

/// Wraps a remote repository with disk caching.
/// Online: fetches from network, caches the response, returns it.
/// Offline: serves from cache, throws if no cache exists.
final class OfflineMovieRepository: MovieRepositoryProtocol {

    private let remote: MovieRepositoryProtocol
    private let store: OfflineStore
    private let monitor: NetworkMonitor

    init(remote: MovieRepositoryProtocol, store: OfflineStore, monitor: NetworkMonitor) {
        self.remote = remote
        self.store = store
        self.monitor = monitor
    }

    // MARK: - Cache Keys

    private enum CacheKey {
        static func trending(page: Int) -> String { "trending_page_\(page)" }
        static func detail(id: Int) -> String { "detail_\(id)" }
        static func credits(id: Int) -> String { "credits_\(id)" }
        static let configuration = "configuration"
    }

    // MARK: - MovieRepositoryProtocol

    func fetchTrending(page: Int) async throws -> PagedResponse<Movie> {
        try await fetchWithCache(
            key: CacheKey.trending(page: page),
            type: PagedResponse<Movie>.self
        ) {
            try await remote.fetchTrending(page: page)
        }
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        try await fetchWithCache(
            key: CacheKey.detail(id: id),
            type: MovieDetail.self
        ) {
            try await remote.fetchMovieDetail(id: id)
        }
    }

    func fetchMovieCredits(id: Int) async throws -> Credits {
        try await fetchWithCache(
            key: CacheKey.credits(id: id),
            type: Credits.self
        ) {
            try await remote.fetchMovieCredits(id: id)
        }
    }

    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie> {
        try await remote.searchMovies(query: query, page: page)
    }

    func searchTVShows(query: String, page: Int) async throws -> PagedResponse<TVShow> {
        try await remote.searchTVShows(query: query, page: page)
    }

    func fetchConfiguration() async throws -> TMDBConfiguration {
        try await fetchWithCache(
            key: CacheKey.configuration,
            type: TMDBConfiguration.self
        ) {
            try await remote.fetchConfiguration()
        }
    }

    // MARK: - Private

    private func fetchWithCache<T: Codable>(
        key: String,
        type: T.Type,
        fetch: () async throws -> T
    ) async throws -> T {
        let isConnected = monitor.isConnected

        if isConnected {
            do {
                let result = try await fetch()
                await store.save(result, forKey: key)
                return result
            } catch {
                // Network failed while online — fall back to cache
                if let cached = await store.load(type, forKey: key) {
                    return cached
                }
                throw error
            }
        }

        // Offline — serve from cache
        if let cached = await store.load(type, forKey: key) {
            return cached
        }

        throw NetworkError.noInternetConnection
    }
}
