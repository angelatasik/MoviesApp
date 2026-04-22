//
//  FavoritesManager.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 18.4.26.
//

import Foundation
import SwiftData

@MainActor
@Observable
public final class FavoritesManager {

    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func isFavorite(movieId: Int) -> Bool {
        let descriptor = FetchDescriptor<FavoriteMovie>(
            predicate: #Predicate { $0.id == movieId }
        )
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    public func toggleFavorite(movie: Movie) throws {
        if isFavorite(movieId: movie.id) {
            try removeFavorite(movieId: movie.id)
        } else {
            try addFavorite(movie: movie)
        }
    }

    private func addFavorite(movie: Movie) throws {
        let favorite = FavoriteMovie(from: movie)
        modelContext.insert(favorite)
        try modelContext.save()
    }

    private func removeFavorite(movieId: Int) throws {
        let descriptor = FetchDescriptor<FavoriteMovie>(
            predicate: #Predicate { $0.id == movieId }
        )

        if let favorite = try modelContext.fetch(descriptor).first {
            modelContext.delete(favorite)
            try modelContext.save()
        }
    }
}
