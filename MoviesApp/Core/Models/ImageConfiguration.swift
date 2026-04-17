//
//  ImageConfiguration.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

// MARK: - TMDBConfiguration

struct TMDBConfiguration: Decodable, Sendable {
    let images: ImageConfiguration
}

// MARK: - ImageConfiguration

struct ImageConfiguration: Decodable, Sendable {

    // MARK: - Properties

    let secureBaseUrl: String
    let posterSizes: [String]
    let backdropSizes: [String]
    let profileSizes: [String]

    // MARK: - URL Builders

    func posterURL(path: String, width: CGFloat) -> URL? {
        let size = bestPosterSize(for: width)
        return URL(string: "\(secureBaseUrl)\(size)\(path)")
    }

    func backdropURL(path: String, width: CGFloat) -> URL? {
        let size = bestBackdropSize(for: width)
        return URL(string: "\(secureBaseUrl)\(size)\(path)")
    }

    func profileURL(path: String, width: CGFloat) -> URL? {
        return URL(string: "\(secureBaseUrl)w185\(path)")
    }

    // MARK: - Size Selection

    private func bestPosterSize(for width: CGFloat) -> String {
        switch width {
        case ..<100: return "w92"
        case ..<200: return "w154"
        case ..<300: return "w185"
        case ..<400: return "w342"
        case ..<600: return "w500"
        default: return "w780"
        }
    }

    private func bestBackdropSize(for width: CGFloat) -> String {
        switch width {
        case ..<400: return "w300"
        case ..<900: return "w780"
        default: return "w1280"
        }
    }
}
