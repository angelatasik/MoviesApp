//
//  Endpoint.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

public enum Endpoint: Requestable {

    // MARK: - Cases

    case trending(page: Int)
    case movieDetail(id: Int, appendToResponse: [String] = [])
    case movieCredits(id: Int)
    case searchMovies(query: String, page: Int)
    case searchTV(query: String, page: Int)
    case configuration

    // MARK: - Requestable

    public var path: String {
        switch self {
        case .trending:
            return "trending/movie/week"
        case .movieDetail(let id, _):
            return "movie/\(id)"
        case .movieCredits(let id):
            return "movie/\(id)/credits"
        case .searchMovies:
            return "search/movie"
        case .searchTV:
            return "search/tv"
        case .configuration:
            return "configuration"
        }
    }

    public var queryItems: [URLQueryItem] {
        switch self {
        case .trending(let page):
            return [
                URLQueryItem(name: "page", value: String(page))
            ]
        case .movieDetail(_, let appendToResponse):
            guard !appendToResponse.isEmpty else { return [] }
            return [
                URLQueryItem(
                    name: "append_to_response",
                    value: appendToResponse.joined(separator: ",")
                )
            ]
        case .movieCredits:
            return []
        case .searchMovies(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .searchTV(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .configuration:
            return []
        }
    }
}
