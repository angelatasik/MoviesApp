//
//  MovieDetail.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import Foundation

// MARK: - MovieDetail

public struct MovieDetail: Codable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let releaseDate: String?
    public let runtime: Int?
    public let status: String
    public let tagline: String?
    public let popularity: Double
    public let budget: Int
    public let revenue: Int
    public let genres: [Genre]
    public let productionCompanies: [ProductionCompany]
    public let spokenLanguages: [SpokenLanguage]

    public init(
        id: Int, title: String, overview: String, posterPath: String?, backdropPath: String?,
        voteAverage: Double, voteCount: Int, releaseDate: String?, runtime: Int?, status: String,
        tagline: String?, popularity: Double, budget: Int, revenue: Int,
        genres: [Genre], productionCompanies: [ProductionCompany], spokenLanguages: [SpokenLanguage]
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.status = status
        self.tagline = tagline
        self.popularity = popularity
        self.budget = budget
        self.revenue = revenue
        self.genres = genres
        self.productionCompanies = productionCompanies
        self.spokenLanguages = spokenLanguages
    }
}

// MARK: - Genre

public struct Genre: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - ProductionCompany

public struct ProductionCompany: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let logoPath: String?

    public init(id: Int, name: String, logoPath: String?) {
        self.id = id
        self.name = name
        self.logoPath = logoPath
    }
}

// MARK: - SpokenLanguage

public struct SpokenLanguage: Codable, Sendable {
    public let englishName: String
    public let name: String

    public init(englishName: String, name: String) {
        self.englishName = englishName
        self.name = name
    }
}
