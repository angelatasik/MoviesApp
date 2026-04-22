//
//  TVShow.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import Foundation

public struct TVShow: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let firstAirDate: String?
    public let genreIds: [Int]
    public let popularity: Double

    public init(
        id: Int,
        name: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        voteCount: Int,
        firstAirDate: String?,
        genreIds: [Int],
        popularity: Double
    ) {
        self.id = id
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.firstAirDate = firstAirDate
        self.genreIds = genreIds
        self.popularity = popularity
    }
}
