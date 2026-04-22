//
//  ImageConfiguration.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

// MARK: - Size Constants

public nonisolated enum ImageSize: Sendable {
    // Poster
    public static let posterXSmall = "w92"
    public static let posterSmall = "w154"
    public static let posterMedium = "w185"
    public static let posterLarge = "w342"
    public static let posterXLarge = "w500"
    public static let posterOriginal = "w780"

    // Backdrop
    public static let backdropSmall = "w300"
    public static let backdropMedium = "w780"
    public static let backdropLarge = "w1280"

    // Profile
    public static let profileSmall = "w45"
    public static let profileLarge = "w185"
}

// MARK: - TMDBConfiguration

public struct TMDBConfiguration: Codable, Sendable {
    public let images: ImageConfiguration

    public init(images: ImageConfiguration) {
        self.images = images
    }
}

// MARK: - ImageConfiguration

public struct ImageConfiguration: Codable, Sendable {

    // MARK: - Properties

    public let secureBaseUrl: String
    public let posterSizes: [String]
    public let backdropSizes: [String]
    public let profileSizes: [String]

    public init(secureBaseUrl: String, posterSizes: [String], backdropSizes: [String], profileSizes: [String]) {
        self.secureBaseUrl = secureBaseUrl
        self.posterSizes = posterSizes
        self.backdropSizes = backdropSizes
        self.profileSizes = profileSizes
    }

    // MARK: - URL Builders

    public func imageURL(path: String, size: String) -> URL? {
        URL(string: "\(secureBaseUrl)\(size)\(path)")
    }

    public func posterURL(path: String, width: CGFloat) -> URL? {
        imageURL(path: path, size: bestPosterSize(for: width))
    }

    public func backdropURL(path: String, width: CGFloat) -> URL? {
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
