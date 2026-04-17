//
//  AppDependencies.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

final class AppDependencies {
    static let shared = AppDependencies()

    // MARK: - Dependencies

    private(set) lazy var networkClient: NetworkClient = {
        guard let baseURL = URL(string: AppEnvironment.baseURL) else {
            fatalError("Invalid base URL")
        }
        return URLSessionNetworkClient(
            baseURL: baseURL,
            interceptor: AuthInterceptor(token: AppEnvironment.accessToken)
        )
    }()

    private(set) lazy var movieRepository: MovieRepositoryProtocol = {
        MovieRepository(networkClient: networkClient)
    }()
    
    private(set) lazy var imageConfigurationCache: ImageConfigurationCaching = {
        ImageConfigurationCache()
    }()

    private init() {}
}
