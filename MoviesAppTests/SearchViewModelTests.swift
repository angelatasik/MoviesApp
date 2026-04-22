//
//  SearchViewModelTests.swift
//  MoviesAppTests
//
//  Created by Angela Tasikj on 20.4.26.
//

import Testing
@testable import MoviesApp
import MoviesCore

// MARK: - Mock Repository

@MainActor
final class MockMovieRepository: MovieRepositoryProtocol {

    // Configurable responses
    var movieSearchResult: Result<PagedResponse<Movie>, Error> = .success(
        PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
    )
    var tvShowSearchResult: Result<PagedResponse<TVShow>, Error> = .success(
        PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
    )

    // Call tracking
    var searchMoviesCallCount = 0
    var searchTVShowsCallCount = 0
    var lastMovieQuery: String?
    var lastMoviePage: Int?
    var lastTVQuery: String?
    var lastTVPage: Int?

    // Delay simulation for testing loading states
    var artificialDelay: UInt64 = 0

    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie> {
        searchMoviesCallCount += 1
        lastMovieQuery = query
        lastMoviePage = page
        if artificialDelay > 0 {
            try await Task.sleep(nanoseconds: artificialDelay)
        }
        return try movieSearchResult.get()
    }

    func searchTVShows(query: String, page: Int) async throws -> PagedResponse<TVShow> {
        searchTVShowsCallCount += 1
        lastTVQuery = query
        lastTVPage = page
        if artificialDelay > 0 {
            try await Task.sleep(nanoseconds: artificialDelay)
        }
        return try tvShowSearchResult.get()
    }

    // Unused protocol requirements
    func fetchTrending(page: Int) async throws -> PagedResponse<Movie> {
        PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        fatalError("Not expected in SearchViewModel tests")
    }

    func fetchMovieCredits(id: Int) async throws -> Credits {
        fatalError("Not expected in SearchViewModel tests")
    }

    func fetchConfiguration() async throws -> TMDBConfiguration {
        fatalError("Not expected in SearchViewModel tests")
    }
}

// MARK: - Mock Image Configuration Cache

@MainActor
final class MockImageConfigurationCache: ImageConfigurationCaching {
    var configuration: ImageConfiguration?

    func store(_ configuration: ImageConfiguration) {
        self.configuration = configuration
    }
}

// MARK: - Test Helpers

private struct SUT {
    let viewModel: SearchViewModel
    let repository: MockMovieRepository
    let imageCache: MockImageConfigurationCache
}

@MainActor
private func makeSUT(
    repository: MockMovieRepository? = nil,
    imageCache: MockImageConfigurationCache? = nil
) -> SUT {
    let repo = repository ?? MockMovieRepository()
    let cache = imageCache ?? MockImageConfigurationCache()
    let viewModel = SearchViewModel(repository: repo, imageCache: cache)
    return SUT(viewModel: viewModel, repository: repo, imageCache: cache)
}

private func makeMovies(count: Int) -> [Movie] {
    (0..<count).map { index in
        Movie(
            id: index,
            title: "Movie \(index)",
            overview: "Overview \(index)",
            posterPath: "/poster\(index).jpg",
            backdropPath: nil,
            voteAverage: 7.0 + Double(index) * 0.1,
            voteCount: 100,
            releaseDate: "2026-01-01",
            genreIds: [28],
            popularity: 50.0
        )
    }
}

private func makeTVShows(count: Int) -> [TVShow] {
    (0..<count).map { index in
        TVShow(
            id: 100 + index,
            name: "Show \(index)",
            overview: "Overview \(index)",
            posterPath: "/show\(index).jpg",
            backdropPath: nil,
            voteAverage: 8.0,
            voteCount: 200,
            firstAirDate: "2026-03-01",
            genreIds: [18],
            popularity: 60.0
        )
    }
}

// MARK: - Tests

@Suite("SearchViewModel Tests")
@MainActor
struct SearchViewModelTests {

    // MARK: - Initial State

    @Test("Initial state has empty results, no loading, no error")
    func initialState() {
        let sut = makeSUT().viewModel

        #expect(sut.query == "")
        #expect(sut.results.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.isLoadingMore == false)
        #expect(sut.errorMessage == nil)
        #expect(sut.searchType == .movies)
    }

    @Test("Init reads image configuration from cache")
    func initReadsImageConfig() {
        let cache = MockImageConfigurationCache()
        let config = ImageConfiguration(
            secureBaseUrl: "https://image.tmdb.org/t/p/",
            posterSizes: ["w500"],
            backdropSizes: ["w780"],
            profileSizes: ["w185"]
        )
        cache.configuration = config

        let sut = SearchViewModel(repository: MockMovieRepository(), imageCache: cache)

        #expect(sut.imageConfig?.secureBaseUrl == "https://image.tmdb.org/t/p/")
    }

    // MARK: - Successful Movie Search

    @Test("Search movies returns results after debounce")
    func searchMoviesSuccess() async throws {
        let repo = MockMovieRepository()
        let movies = makeMovies(count: 3)
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: movies, totalPages: 1, totalResults: 3)
        )
        let sut = makeSUT(repository: repo).viewModel

        sut.onQueryChange("Batman")

        // Wait for debounce (400ms) + processing time
        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(sut.results.count == 3)
        #expect(sut.results[0].title == "Movie 0")
        #expect(sut.results[1].title == "Movie 1")
        #expect(sut.results[2].title == "Movie 2")
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
        #expect(repo.searchMoviesCallCount == 1)
        #expect(repo.lastMovieQuery == "Batman")
        #expect(repo.lastMoviePage == 1)
    }

    @Test("New query replaces previous results")
    func newQueryReplacesOldResults() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: makeMovies(count: 3), totalPages: 1, totalResults: 3)
        )
        let sut = makeSUT(repository: repo).viewModel

        // First search
        sut.onQueryChange("Batman")
        try await Task.sleep(nanoseconds: 600_000_000)
        #expect(sut.results.count == 3)
        // Second search with different results
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: makeMovies(count: 1), totalPages: 1, totalResults: 1)
        )
        sut.onQueryChange("Joker")
        try await Task.sleep(nanoseconds: 600_000_000)
        // Should NOT contain old results
        #expect(sut.results.count == 1)
        #expect(repo.searchMoviesCallCount == 2)
    }

    // MARK: - Successful TV Show Search

    @Test("Search TV shows returns results when search type is tvShows")
    func searchTVShowsSuccess() async throws {
        let repo = MockMovieRepository()
        let shows = makeTVShows(count: 2)
        repo.tvShowSearchResult = .success(
            PagedResponse(page: 1, results: shows, totalPages: 1, totalResults: 2)
        )
        let sut = makeSUT(repository: repo).viewModel

        sut.onSearchTypeChange(.tvShows)
        sut.onQueryChange("Breaking")

        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(sut.results.count == 2)
        #expect(sut.results[0].title == "Show 0")
        #expect(sut.searchType == .tvShows)
        #expect(repo.searchTVShowsCallCount == 1)
        #expect(repo.lastTVQuery == "Breaking")
    }

    // MARK: - Empty Query

    @Test("Empty query clears results without calling repository")
    func emptyQueryClearsResults() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: makeMovies(count: 2), totalPages: 1, totalResults: 2)
        )
        let sut = makeSUT(repository: repo).viewModel

        // First, perform a search
        sut.onQueryChange("Batman")
        try await Task.sleep(nanoseconds: 600_000_000)
        #expect(sut.results.count == 2)

        // Now clear the query
        let callCountBefore = repo.searchMoviesCallCount
        sut.onQueryChange("")

        #expect(sut.results.isEmpty)
        #expect(sut.isLoading == false)
        #expect(repo.searchMoviesCallCount == callCountBefore)
    }

    @Test("Whitespace-only query clears results")
    func whitespaceQueryClearsResults() {
        let result = makeSUT()
        let sut = result.viewModel
        let repo = result.repository

        sut.onQueryChange("   ")

        #expect(sut.results.isEmpty)
        #expect(repo.searchMoviesCallCount == 0)
    }

    // MARK: - Empty Results (No Matches)

    @Test("Search with no matches returns empty results without error")
    func searchNoMatches() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        )
        let sut = makeSUT(repository: repo).viewModel

        sut.onQueryChange("xyznonexistent")
        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(sut.results.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    // MARK: - Error Handling

    @Test("Network error sets errorMessage")
    func networkErrorSetsMessage() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .failure(NetworkError.noInternetConnection)
        let sut = makeSUT(repository: repo).viewModel

        sut.onQueryChange("Batman")
        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(sut.errorMessage != nil)
        #expect(sut.errorMessage == "No internet connection.")
        #expect(sut.isLoading == false)
        #expect(sut.results.isEmpty)
    }

    @Test("Server error sets errorMessage with status code")
    func serverErrorSetsMessage() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .failure(NetworkError.statusCode(500))
        let sut = makeSUT(repository: repo).viewModel

        sut.onQueryChange("Test")
        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(sut.errorMessage == "Server returned status code 500.")
        #expect(sut.isLoading == false)
    }

    @Test("Cancellation error does NOT set errorMessage")
    func cancellationErrorIgnored() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .failure(CancellationError())
        let sut = makeSUT(repository: repo).viewModel

        sut.onQueryChange("Batman")
        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(sut.errorMessage == nil)
    }

    // MARK: - Debounce Behavior

    @Test("Rapid queries cancel previous searches, only last fires")
    func debounceCancelsPreviousSearches() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: makeMovies(count: 1), totalPages: 1, totalResults: 1)
        )
        let sut = makeSUT(repository: repo).viewModel

        // Rapid-fire queries — only the last one should survive debounce
        sut.onQueryChange("B")
        sut.onQueryChange("Ba")
        sut.onQueryChange("Bat")
        sut.onQueryChange("Batm")
        sut.onQueryChange("Batman")

        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(repo.searchMoviesCallCount == 1)
        #expect(repo.lastMovieQuery == "Batman")
    }

    // MARK: - Search Type Change

    @Test("Changing search type re-triggers search with current query")
    func searchTypeChangeRetriggers() async throws {
        let repo = MockMovieRepository()
        let movies = makeMovies(count: 2)
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: movies, totalPages: 1, totalResults: 2)
        )
        let shows = makeTVShows(count: 3)
        repo.tvShowSearchResult = .success(
            PagedResponse(page: 1, results: shows, totalPages: 1, totalResults: 3)
        )
        let sut = makeSUT(repository: repo).viewModel

        // Initial movie search
        sut.onQueryChange("Action")
        try await Task.sleep(nanoseconds: 600_000_000)
        #expect(sut.results.count == 2)

        // Switch to TV shows — should re-search with same query
        sut.onSearchTypeChange(.tvShows)
        try await Task.sleep(nanoseconds: 600_000_000)

        #expect(sut.results.count == 3)
        #expect(sut.results[0].title == "Show 0")
        #expect(repo.searchTVShowsCallCount == 1)
    }

    @Test("Changing search type with empty query does not trigger search")
    func searchTypeChangeEmptyQuery() {
        let result = makeSUT()
        let sut = result.viewModel
        let repo = result.repository

        sut.onSearchTypeChange(.tvShows)

        #expect(sut.searchType == .tvShows)
        #expect(repo.searchTVShowsCallCount == 0)
        #expect(repo.searchMoviesCallCount == 0)
    }

    // MARK: - Pagination

    @Test("loadMoreIfNeeded fetches next page when near end of results")
    func paginationLoadsNextPage() async throws {
        let repo = MockMovieRepository()
        let firstPage = makeMovies(count: 20)
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: firstPage, totalPages: 3, totalResults: 60)
        )
        let sut = makeSUT(repository: repo).viewModel

        // Trigger first page
        sut.onQueryChange("Action")
        try await Task.sleep(nanoseconds: 600_000_000)
        #expect(sut.results.count == 20)

        // Configure second page
        let secondPage = makeMovies(count: 20)
        repo.movieSearchResult = .success(
            PagedResponse(page: 2, results: secondPage, totalPages: 3, totalResults: 60)
        )

        // Trigger pagination by scrolling near the end (threshold = count - 5 = 15)
        let nearEndItem = sut.results[16]
        await sut.loadMoreIfNeeded(currentItem: nearEndItem)

        #expect(sut.results.count == 40)
        #expect(repo.searchMoviesCallCount == 2)
        #expect(repo.lastMoviePage == 2)
    }

    @Test("loadMoreIfNeeded does nothing when not near threshold")
    func paginationIgnoresEarlyItems() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: makeMovies(count: 20), totalPages: 3, totalResults: 60)
        )
        let sut = makeSUT(repository: repo).viewModel

        sut.onQueryChange("Action")
        try await Task.sleep(nanoseconds: 600_000_000)

        let earlyItem = sut.results[0]
        await sut.loadMoreIfNeeded(currentItem: earlyItem)

        // Should NOT have loaded a second page
        #expect(repo.searchMoviesCallCount == 1)
        #expect(sut.results.count == 20)
    }

    @Test("loadMoreIfNeeded does nothing on last page")
    func paginationStopsAtLastPage() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: makeMovies(count: 10), totalPages: 1, totalResults: 10)
        )
        let sut = makeSUT(repository: repo).viewModel

        sut.onQueryChange("Action")
        try await Task.sleep(nanoseconds: 600_000_000)

        let lastItem = sut.results[9]
        await sut.loadMoreIfNeeded(currentItem: lastItem)

        #expect(repo.searchMoviesCallCount == 1)
    }

    @Test("Pagination error preserves existing results")
    func paginationErrorKeepsResults() async throws {
        let repo = MockMovieRepository()
        repo.movieSearchResult = .success(
            PagedResponse(page: 1, results: makeMovies(count: 20), totalPages: 3, totalResults: 60)
        )
        let sut = makeSUT(repository: repo).viewModel
        sut.onQueryChange("Action")
        try await Task.sleep(nanoseconds: 600_000_000)
        #expect(sut.results.count == 20)
        // Now fail second page
        repo.movieSearchResult = .failure(NetworkError.noInternetConnection)
        await sut.loadMoreIfNeeded(currentItem: sut.results[16])
        // First page should still be visible
        #expect(sut.results.count == 20)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoadingMore == false)
    }
    // MARK: - SearchResult Properties

    @Test("SearchResult.movie exposes correct properties")
    func searchResultMovieProperties() {
        let movie = makeMovies(count: 1)[0]
        let result = SearchViewModel.SearchResult.movie(movie)

        #expect(result.id == 0)
        #expect(result.title == "Movie 0")
        #expect(result.overview == "Overview 0")
        #expect(result.posterPath == "/poster0.jpg")
        #expect(result.date == "2026-01-01")
        #expect(result.rating == 7.0)
    }

    @Test("SearchResult.tvShow exposes correct properties")
    func searchResultTVShowProperties() {
        let show = makeTVShows(count: 1)[0]
        let result = SearchViewModel.SearchResult.tvShow(show)

        #expect(result.id == 100)
        #expect(result.title == "Show 0")
        #expect(result.overview == "Overview 0")
        #expect(result.posterPath == "/show0.jpg")
        #expect(result.date == "2026-03-01")
        #expect(result.rating == 8.0)
    }
}
