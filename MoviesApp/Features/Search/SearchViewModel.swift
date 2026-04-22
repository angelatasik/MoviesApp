//
//  SearchViewModel.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 18.4.26.
//

import Foundation
import MoviesCore

@Observable
@MainActor
final class SearchViewModel {

    // MARK: - Types

    enum SearchType: String, CaseIterable, Identifiable {
        case movies
        case tvShows

        var id: String { rawValue }

        var title: String {
            switch self {
            case .movies: return Strings.Search.movies
            case .tvShows: return Strings.Search.tvShows
            }
        }
    }

    enum SearchResult: Identifiable, Hashable {
        case movie(Movie)
        case tvShow(TVShow)

        var id: Int {
            switch self {
            case .movie(let movie): return movie.id
            case .tvShow(let show): return show.id
            }
        }

        var title: String {
            switch self {
            case .movie(let movie): return movie.title
            case .tvShow(let show): return show.name
            }
        }

        var overview: String {
            switch self {
            case .movie(let movie): return movie.overview
            case .tvShow(let show): return show.overview
            }
        }

        var posterPath: String? {
            switch self {
            case .movie(let movie): return movie.posterPath
            case .tvShow(let show): return show.posterPath
            }
        }

        var date: String? {
            switch self {
            case .movie(let movie): return movie.releaseDate
            case .tvShow(let show): return show.firstAirDate
            }
        }

        var rating: Double {
            switch self {
            case .movie(let movie): return movie.voteAverage
            case .tvShow(let show): return show.voteAverage
            }
        }
    }

    // MARK: - State

    var query = ""
    var searchType: SearchType = .movies
    var results: [SearchResult] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var imageConfig: ImageConfiguration?

    // MARK: - Dependencies

    private let repository: MovieRepositoryProtocol
    private let imageCache: ImageConfigurationCaching

    // MARK: - Private State

    private var searchTask: Task<Void, Never>?
    private var currentPage = 1
    private var totalPages = 1
    private var lastQuery = ""
    private static let debounceDuration: UInt64 = 400_000_000 // 400ms

    // MARK: - Init

    init(
        repository: MovieRepositoryProtocol,
        imageCache: ImageConfigurationCaching
    ) {
        self.repository = repository
        self.imageCache = imageCache
        self.imageConfig = imageCache.configuration
    }

    // MARK: - Public API

    func onQueryChange(_ newQuery: String) {
        query = newQuery
        searchTask?.cancel()

        let trimmed = newQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            isLoading = false
            resetPagination()
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: Self.debounceDuration)
            guard !Task.isCancelled else { return }
            resetPagination()
            await performSearch(query: trimmed, page: 1)
        }
    }

    func onSearchTypeChange(_ type: SearchType) {
        searchType = type
        if !query.isEmpty {
            onQueryChange(query)
        }
    }

    func loadMoreIfNeeded(currentItem: SearchResult) async {
        guard let index = results.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let threshold = results.count - 5
        guard index >= threshold else { return }
        await loadNextPage()
    }

    // MARK: - Private

    private func performSearch(query: String, page: Int) async {
        if page == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        defer {
            isLoading = false
            isLoadingMore = false
        }

        do {
            switch searchType {
            case .movies:
                let response = try await repository.searchMovies(query: query, page: page)
                let newResults = response.results.map { SearchResult.movie($0) }
                if page == 1 {
                    results = newResults
                } else {
                    results.append(contentsOf: newResults)
                }
                currentPage = response.page
                totalPages = response.totalPages
            case .tvShows:
                let response = try await repository.searchTVShows(query: query, page: page)
                let newResults = response.results.map { SearchResult.tvShow($0) }
                if page == 1 {
                    results = newResults
                } else {
                    results.append(contentsOf: newResults)
                }
                currentPage = response.page
                totalPages = response.totalPages
            }
            lastQuery = query
        } catch {
            if !(error is CancellationError) {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func loadNextPage() async {
        guard !isLoadingMore else { return }
        guard currentPage < totalPages else { return }
        await performSearch(query: lastQuery, page: currentPage + 1)
    }

    private func resetPagination() {
        currentPage = 1
        totalPages = 1
        lastQuery = ""
    }
}
