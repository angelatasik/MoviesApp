//
//  DetailViewModel.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

@Observable
@MainActor
final class DetailViewModel {

    // MARK: - State

    let movie: Movie
    var detail: MovieDetail?
    var credits: Credits?
    var imageConfig: ImageConfiguration?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let repository: MovieRepositoryProtocol
    private let imageCache: ImageConfigurationCaching

    // MARK: - Init

    init(
        movie: Movie,
        repository: MovieRepositoryProtocol,
        imageCache: ImageConfigurationCaching
    ) {
        self.movie = movie
        self.repository = repository
        self.imageCache = imageCache
        self.imageConfig = imageCache.configuration
    }

    // MARK: - Public API

    func onAppear() async {
        guard detail == nil else { return }

        isLoading = true
        defer { isLoading = false }

        async let detailTask = loadDetail()
        async let creditsTask = loadCredits()
        async let configTask = loadImageConfigurationIfNeeded()

        await detailTask
        await creditsTask
        await configTask
    }

    // MARK: - Private

    private func loadDetail() async {
        do {
            detail = try await repository.fetchMovieDetail(id: movie.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadCredits() async {
        do {
            credits = try await repository.fetchMovieCredits(id: movie.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadImageConfigurationIfNeeded() async {
        if let cached = imageCache.configuration {
            imageConfig = cached
            return
        }
        do {
            let config = try await repository.fetchConfiguration()
            imageCache.store(config.images)
            imageConfig = config.images
        } catch {
            print("Failed to load image config: \(error)")
        }
    }
}
