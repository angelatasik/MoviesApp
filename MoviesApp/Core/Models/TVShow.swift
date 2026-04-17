//
//  TVShow.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

struct TVShow: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let firstAirDate: String?
    let genreIds: [Int]
    let popularity: Double
}
