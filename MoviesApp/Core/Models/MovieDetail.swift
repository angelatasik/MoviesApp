//
//  MovieDetail.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

// MARK: - MovieDetail

struct MovieDetail: Decodable, Identifiable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let releaseDate: String?
    let runtime: Int?
    let status: String
    let tagline: String?
    let popularity: Double
    let budget: Int
    let revenue: Int
    let genres: [Genre]
    let productionCompanies: [ProductionCompany]
    let spokenLanguages: [SpokenLanguage]
}

// MARK: - Genre

struct Genre: Decodable, Identifiable, Sendable {
    let id: Int
    let name: String
}

// MARK: - ProductionCompany

struct ProductionCompany: Decodable, Identifiable, Sendable {
    let id: Int
    let name: String
    let logoPath: String?
}

// MARK: - SpokenLanguage

struct SpokenLanguage: Decodable, Sendable {
    let englishName: String
    let name: String
}
