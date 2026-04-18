//
//  FavoriteMovie.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 18.4.26.
//

import Foundation
import SwiftData

@Model
final class FavoriteMovie {
    @Attribute(.unique) var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double
    var voteCount: Int
    var releaseDate: String?
    var addedDate: Date
    
    init(from movie: Movie) {
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
    func toMovie() -> Movie {
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
