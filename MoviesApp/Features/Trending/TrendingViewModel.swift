//
//  TrendingViewModel.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

@Observable
@MainActor
final class TrendingViewModel {

    // MARK: - Published State

    var movies: [Movie] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var imageConfig: ImageConfiguration?
    
    // MARK: - Private State

    private var currentPage = 1
    private var totalPages = 1

    private let repository: MovieRepositoryProtocol
    private let imageCache: ImageConfigurationCaching
    private let prefetcher: ContentPrefetcher
    private let networkMonitor: NetworkMonitor

    // MARK: - Init

    init(
        repository: MovieRepositoryProtocol,
        imageCache: ImageConfigurationCaching,
        prefetcher: ContentPrefetcher,
        networkMonitor: NetworkMonitor
    ) {
        self.repository = repository
        self.imageCache = imageCache
        self.prefetcher = prefetcher
        self.networkMonitor = networkMonitor
        self.imageConfig = imageCache.configuration
    }

    // MARK: - Public API

    func onAppear() async {
        await loadImageConfigurationIfNeeded()
        guard movies.isEmpty else { return }
        await loadFirstPage()
    }

    func refresh() async {
        currentPage = 1
        movies = []
        await loadFirstPage()
    }

    func loadMoreIfNeeded(currentItem: Movie) async {
        guard let index = movies.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let threshold = movies.count - 5
        guard index >= threshold else { return }
        guard networkMonitor.isConnected else { return }
        await loadNextPage()
    }

    // MARK: - Private

    private func loadFirstPage() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await repository.fetchTrending(page: 1)
            movies = response.results
            currentPage = response.page
            totalPages = response.totalPages
            await prefetcher.prefetch(movies: response.results)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadNextPage() async {
        guard !isLoadingMore else { return }
        guard currentPage < totalPages else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let response = try await repository.fetchTrending(page: currentPage + 1)
            movies.append(contentsOf: response.results)
            currentPage = response.page
            await prefetcher.prefetch(movies: response.results)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadImageConfigurationIfNeeded() async {
        guard imageCache.configuration == nil else { return }
        do {
            let config = try await repository.fetchConfiguration()
            imageCache.store(config.images)
            imageConfig = config.images
        } catch {
            print("Failed to load image config: \(error)")
        }
    }
}
