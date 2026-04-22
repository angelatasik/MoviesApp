//
//  Movie.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import Foundation

public struct Movie: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let releaseDate: String?
    public let genreIds: [Int]
    public let popularity: Double

    public init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        voteCount: Int,
        releaseDate: String?,
        genreIds: [Int],
        popularity: Double
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.releaseDate = releaseDate
        self.genreIds = genreIds
        self.popularity = popularity
    }
}
