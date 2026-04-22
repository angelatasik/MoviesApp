//
//  AppRoute.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI
import MoviesCore

enum AppRoute: Hashable, Sendable {
    case movieDetail(Movie)
    case search
    case favorites
}

extension AppRoute {
    @ViewBuilder
    var destination: some View {
        switch self {
        case .movieDetail(let movie):
            DetailView(movie: movie)
        case .search:
            SearchView()
        case .favorites:
            FavoritesView()
        }
    }
}
