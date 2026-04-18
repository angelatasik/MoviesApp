//
//  DetailViewModel.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation
import SwiftUI

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
    var isFavorite = false

    var favoriteIcon: String {
        isFavorite ? AppIcon.heartFilled : AppIcon.heart
    }

    var favoriteColor: Color {
        isFavorite ? .red : AppColor.primaryText
    }

    var title: String {
        detail?.title ?? movie.title
    }

    var overview: String {
        detail?.overview ?? movie.overview
    }

    var releaseYear: String? {
        let date = detail?.releaseDate ?? movie.releaseDate
        return DateFormatting.yearString(from: date)
    }

    var rating: Double {
        detail?.voteAverage ?? movie.voteAverage
    }

    var starCount: Int {
        Int(rating / 2)
    }

    var formattedRating: String {
        String(format: "%.1f", rating)
    }

    var voteCount: Int {
        detail?.voteCount ?? movie.voteCount
    }

    var runtimeText: String? {
        guard let minutes = detail?.runtime else { return nil }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours == 0 { return "\(mins)min" }
        return "\(hours)h \(mins)min"
    }

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

    func loadFavoriteState(from manager: FavoritesManager) {
        isFavorite = manager.isFavorite(movieId: movie.id)
    }

    func toggleFavorite(using manager: FavoritesManager) {
        isFavorite.toggle()
        do {
            try manager.toggleFavorite(movie: movie)
        } catch {
            isFavorite.toggle()
            errorMessage = error.localizedDescription
        }
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
