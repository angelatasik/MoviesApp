//
//  ImageConfiguration.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

// MARK: - TMDBConfiguration

struct TMDBConfiguration: Codable, Sendable {
    let images: ImageConfiguration
}

// MARK: - ImageConfiguration

struct ImageConfiguration: Codable, Sendable {

    // MARK: - Size Constants

    enum Size {
        // Poster
        static let posterXSmall = "w92"
        static let posterSmall = "w154"
        static let posterMedium = "w185"
        static let posterLarge = "w342"
        static let posterXLarge = "w500"
        static let posterOriginal = "w780"

        // Backdrop
        static let backdropSmall = "w300"
        static let backdropMedium = "w780"
        static let backdropLarge = "w1280"

        // Profile
        static let profileSmall = "w45"
        static let profileLarge = "w185"
    }

    // MARK: - Properties

    let secureBaseUrl: String
    let posterSizes: [String]
    let backdropSizes: [String]
    let profileSizes: [String]

    // MARK: - URL Builders

    func imageURL(path: String, size: String) -> URL? {
        URL(string: "\(secureBaseUrl)\(size)\(path)")
    }

    func posterURL(path: String, width: CGFloat) -> URL? {
        imageURL(path: path, size: bestPosterSize(for: width))
    }

    func backdropURL(path: String, width: CGFloat) -> URL? {
        imageURL(path: path, size: bestBackdropSize(for: width))
    }

    // MARK: - Size Selection

    private func bestPosterSize(for width: CGFloat) -> String {
        switch width {
        case ..<100: return Size.posterXSmall
        case ..<200: return Size.posterSmall
        case ..<300: return Size.posterMedium
        case ..<400: return Size.posterLarge
        case ..<600: return Size.posterXLarge
        default: return Size.posterOriginal
        }
    }

    private func bestBackdropSize(for width: CGFloat) -> String {
        switch width {
        case ..<400: return Size.backdropSmall
        case ..<900: return Size.backdropMedium
        default: return Size.backdropLarge
        }
    }
}
