//
//  MovieRepositoryProtocol.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

protocol MovieRepositoryProtocol {
    func fetchTrending(page: Int) async throws -> PagedResponse<Movie>
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
    func fetchMovieCredits(id: Int) async throws -> Credits
    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie>
}
