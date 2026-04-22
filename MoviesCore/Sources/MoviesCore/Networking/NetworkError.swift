//
//  NetworkError.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

public enum NetworkError: LocalizedError {

    // MARK: - Cases

    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)
    case noInternetConnection
    case unauthorized
    case unknown(Error)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .statusCode(let code):
            return "Server returned status code \(code)."
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection."
        case .unauthorized:
            return "Unauthorized. Check your API token."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
