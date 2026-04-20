//
//  AppDependencies.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

@MainActor
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

    let offlineStore = OfflineStore()

    private(set) lazy var movieRepository: MovieRepositoryProtocol = {
        OfflineMovieRepository(
            remote: MovieRepository(networkClient: networkClient),
            store: offlineStore,
            monitor: networkMonitor
        )
    }()

    private(set) lazy var imageConfigurationCache: ImageConfigurationCaching = {
        ImageConfigurationCache()
    }()

    private(set) lazy var contentPrefetcher: ContentPrefetcher = {
        ContentPrefetcher(
            repository: movieRepository,
            imageConfig: { [weak self] in self?.imageConfigurationCache.configuration }
        )
    }()

    let networkMonitor = NetworkMonitor()

    private init() {}
}
