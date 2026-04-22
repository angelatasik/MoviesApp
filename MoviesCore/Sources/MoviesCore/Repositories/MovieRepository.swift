//
//  MovieRepository.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

public final class MovieRepository: MovieRepositoryProtocol, @unchecked Sendable {

    // MARK: - Properties

    private let networkClient: NetworkClient

    // MARK: - Initialization

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - MovieRepositoryProtocol

    public func fetchTrending(page: Int) async throws -> PagedResponse<Movie> {
        try await networkClient.fetch(Endpoint.trending(page: page))
    }

    public func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        try await networkClient.fetch(Endpoint.movieDetail(id: id))
    }

    public func fetchMovieCredits(id: Int) async throws -> Credits {
        try await networkClient.fetch(Endpoint.movieCredits(id: id))
    }

    public func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie> {
        try await networkClient.fetch(Endpoint.searchMovies(query: query, page: page))
    }

    public func searchTVShows(query: String, page: Int) async throws -> PagedResponse<TVShow> {
        try await networkClient.fetch(Endpoint.searchTV(query: query, page: page))
    }

    public func fetchConfiguration() async throws -> TMDBConfiguration {
        try await networkClient.fetch(Endpoint.configuration)
    }
}
