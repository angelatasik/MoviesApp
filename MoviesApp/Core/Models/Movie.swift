//
//  Movie.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

struct Movie: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let releaseDate: String?
    let genreIds: [Int]
    let popularity: Double
}
