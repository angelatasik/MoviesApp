//
//  NetworkErrorTests.swift
//  MoviesAppTests
//
//  Created by Angela Tasikj on 20.4.26.
//

import Testing
import Foundation
@testable import MoviesApp
import MoviesCore

@Suite("NetworkError Tests")
struct NetworkErrorTests {

    // MARK: - Simple Cases

    @Test("invalidURL has correct description")
    func invalidURLDescription() {
        let error = NetworkError.invalidURL
        #expect(error.errorDescription == "Invalid URL.")
    }

    @Test("invalidResponse has correct description")
    func invalidResponseDescription() {
        let error = NetworkError.invalidResponse
        #expect(error.errorDescription == "Invalid response from server.")
    }

    @Test("noInternetConnection has correct description")
    func noInternetConnectionDescription() {
        let error = NetworkError.noInternetConnection
        #expect(error.errorDescription == "No internet connection.")
    }

    @Test("unauthorized has correct description")
    func unauthorizedDescription() {
        let error = NetworkError.unauthorized
        #expect(error.errorDescription == "Unauthorized. Check your API token.")
    }

    // MARK: - statusCode

    @Test("statusCode includes the provided code in description")
    func statusCodeDescription() {
        let error = NetworkError.statusCode(500)
        #expect(error.errorDescription == "Server returned status code 500.")
    }

    @Test("statusCode works with different codes")
    func statusCodeWithVariousCodes() {
        let error404 = NetworkError.statusCode(404)
        let error401 = NetworkError.statusCode(401)
        let error503 = NetworkError.statusCode(503)

        #expect(error404.errorDescription == "Server returned status code 404.")
        #expect(error401.errorDescription == "Server returned status code 401.")
        #expect(error503.errorDescription == "Server returned status code 503.")
    }

    // MARK: - decodingFailed

    @Test("decodingFailed description includes underlying error message")
    func decodingFailedDescription() {
        let underlyingError = NSError(
            domain: "DecodingTest",
            code: 42,
            userInfo: [NSLocalizedDescriptionKey: "Missing required field"]
        )
        let error = NetworkError.decodingFailed(underlyingError)

        #expect(error.errorDescription == "Decoding failed: Missing required field")
    }

    @Test("decodingFailed description uses localized error")
    func decodingFailedWithLocalizedError() {
        let underlyingError = NSError(
            domain: "JSON",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Unexpected token"]
        )
        let error = NetworkError.decodingFailed(underlyingError)

        #expect(error.errorDescription?.contains("Unexpected token") == true)
        #expect(error.errorDescription?.hasPrefix("Decoding failed:") == true)
    }

    // MARK: - unknown

    @Test("unknown returns underlying error's localized description")
    func unknownDescription() {
        let underlyingError = NSError(
            domain: "UnknownTest",
            code: 999,
            userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]
        )
        let error = NetworkError.unknown(underlyingError)

        #expect(error.errorDescription == "Something went wrong")
    }

    @Test("unknown preserves different underlying errors")
    func unknownWithDifferentErrors() {
        let error1 = NSError(
            domain: "Test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "First error"]
        )
        let error2 = NSError(
            domain: "Test",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Second error"]
        )

        #expect(NetworkError.unknown(error1).errorDescription == "First error")
        #expect(NetworkError.unknown(error2).errorDescription == "Second error")
    }

    // MARK: - All Cases Have Descriptions

    @Test("All NetworkError cases have a non-nil errorDescription")
    func allCasesHaveDescriptions() {
        let testError = NSError(domain: "test", code: 0)

        let cases: [NetworkError] = [
            .invalidURL,
            .invalidResponse,
            .statusCode(500),
            .decodingFailed(testError),
            .noInternetConnection,
            .unauthorized,
            .unknown(testError)
        ]

        for error in cases {
            #expect(error.errorDescription != nil, "Case should have a description")
            #expect(error.errorDescription?.isEmpty == false, "Description should not be empty")
        }
    }
}
