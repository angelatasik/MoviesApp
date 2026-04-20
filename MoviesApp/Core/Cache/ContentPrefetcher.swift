//
//  ContentPrefetcher.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 20.4.26.
//

import Foundation
import Kingfisher

/// Pre-fetches movie details, credits, and all related images concurrently
/// so they are cached for offline access.
actor ContentPrefetcher {

    private let repository: MovieRepositoryProtocol
    private let imageConfig: () -> ImageConfiguration?
    private var prefetchedMovieIds: Set<Int> = []

    init(repository: MovieRepositoryProtocol, imageConfig: @escaping () -> ImageConfiguration?) {
        self.repository = repository
        self.imageConfig = imageConfig
    }

    /// Pre-fetches details, credits, and all images for movies not yet prefetched.
    func prefetch(movies: [Movie]) async {
        let newMovies = movies.filter { !prefetchedMovieIds.contains($0.id) }
        guard !newMovies.isEmpty else { return }

        for movie in newMovies {
            prefetchedMovieIds.insert(movie.id)
        }

        await withTaskGroup(of: Void.self) { group in
            for movie in newMovies {
                group.addTask {
                    await self.prefetchMovie(movie)
                }
            }
        }
    }

    // MARK: - Private

    private func prefetchMovie(_ movie: Movie) async {
        let config = imageConfig()

        // Fetch detail + credits concurrently, then use credits for cast images
        async let detailResult: MovieDetail? = try? await repository.fetchMovieDetail(id: movie.id)
        async let creditsResult: Credits? = try? await repository.fetchMovieCredits(id: movie.id)

        let (_, credits) = await (detailResult, creditsResult)

        // Prefetch all images concurrently
        guard let config else { return }

        let baseUrl = config.secureBaseUrl
        var imageURLs: [URL] = []

        func appendURL(size: String, path: String) {
            if let url = URL(string: "\(baseUrl)\(size)\(path)") {
                imageURLs.append(url)
            }
        }

        if let posterPath = movie.posterPath {
            appendURL(size: ImageSize.posterSmall, path: posterPath)
            appendURL(size: ImageSize.posterXLarge, path: posterPath)
            appendURL(size: ImageSize.posterXSmall, path: posterPath)
        }

        if let backdropPath = movie.backdropPath ?? movie.posterPath {
            appendURL(size: ImageSize.backdropMedium, path: backdropPath)
            appendURL(size: ImageSize.backdropSmall, path: backdropPath)
        }

        if let cast = credits?.cast {
            for member in cast.prefix(15) {
                guard let profilePath = member.profilePath else { continue }
                appendURL(size: ImageSize.profileLarge, path: profilePath)
                appendURL(size: ImageSize.profileSmall, path: profilePath)
            }
        }

        await withCheckedContinuation { continuation in
            let prefetcher = ImagePrefetcher(urls: imageURLs, completionHandler: { _, _, _ in
                continuation.resume()
            })
            prefetcher.maxConcurrentDownloads = 4
            prefetcher.start()
        }
    }
}
