//
//  URLSessionNetworkClient.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

public final class URLSessionNetworkClient: NetworkClient, @unchecked Sendable {

    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private let interceptor: RequestInterceptor?
    private let decoder: JSONDecoder

    // MARK: - Initialization

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        interceptor: RequestInterceptor? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.interceptor = interceptor
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: - NetworkClient

    public func fetch<T: Decodable>(_ endpoint: Requestable) async throws -> T {
        let request = try buildRequest(for: endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - Request Building

private extension URLSessionNetworkClient {
    func buildRequest(for endpoint: Requestable) throws -> URLRequest {
        guard let url = try buildURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let interceptor {
            request = interceptor.intercept(request)
        }

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    func buildURL(for endpoint: Requestable) throws -> URL? {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: true
        ) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        return components.url
    }
}

// MARK: - Response Handling

private extension URLSessionNetworkClient {
    func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try decode(data)
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
    }

    func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        default:
            return .unknown(error)
        }
    }
}
