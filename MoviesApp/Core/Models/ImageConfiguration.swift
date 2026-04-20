//
//  ImageConfiguration.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

// MARK: - Size Constants

nonisolated enum ImageSize: Sendable {
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

// MARK: - TMDBConfiguration

struct TMDBConfiguration: Codable, Sendable {
    let images: ImageConfiguration
}

// MARK: - ImageConfiguration

struct ImageConfiguration: Codable, Sendable {

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
        case ..<100: return ImageSize.posterXSmall
        case ..<200: return ImageSize.posterSmall
        case ..<300: return ImageSize.posterMedium
        case ..<400: return ImageSize.posterLarge
        case ..<600: return ImageSize.posterXLarge
        default: return ImageSize.posterOriginal
        }
    }

    private func bestBackdropSize(for width: CGFloat) -> String {
        switch width {
        case ..<400: return ImageSize.backdropSmall
        case ..<900: return ImageSize.backdropMedium
        default: return ImageSize.backdropLarge
        }
    }
}
