//
//  FavoriteMovie.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 18.4.26.
//

import Foundation
import SwiftData

@Model
public final class FavoriteMovie {
    @Attribute(.unique) public var id: Int
    public var title: String
    public var overview: String
    public var posterPath: String?
    public var backdropPath: String?
    public var voteAverage: Double
    public var voteCount: Int
    public var releaseDate: String?
    public var addedDate: Date

    public init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.releaseDate = movie.releaseDate
        self.addedDate = Date()
    }

    /// Convert back to Movie model for navigation
    public func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage,
            voteCount: voteCount,
            releaseDate: releaseDate,
            genreIds: [],
            popularity: 0
        )
    }
}
