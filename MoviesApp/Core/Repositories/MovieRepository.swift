//
//  MovieRepository.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

final class MovieRepository: MovieRepositoryProtocol {

    // MARK: - Properties

    private let networkClient: NetworkClient

    // MARK: - Initialization

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - MovieRepositoryProtocol

    func fetchTrending(page: Int) async throws -> PagedResponse<Movie> {
        try await networkClient.fetch(Endpoint.trending(page: page))
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        try await networkClient.fetch(Endpoint.movieDetail(id: id))
    }

    func fetchMovieCredits(id: Int) async throws -> Credits {
        try await networkClient.fetch(Endpoint.movieCredits(id: id))
    }

    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie> {
        try await networkClient.fetch(Endpoint.searchMovies(query: query, page: page))
    }
    
    func fetchConfiguration() async throws -> TMDBConfiguration {
        try await networkClient.fetch(Endpoint.configuration)
    }
}
