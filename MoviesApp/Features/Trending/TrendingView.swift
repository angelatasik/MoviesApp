//
//  TrendingView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI

struct TrendingView: View {

    @State private var viewModel: TrendingViewModel
    @Environment(Router.self) private var router

    init() {
        _viewModel = State(
            initialValue: TrendingViewModel(
                repository: AppDependencies.shared.movieRepository,
                imageCache: AppDependencies.shared.imageConfigurationCache
            )
        )
    }

    var body: some View {
        ZStack {
            AppGradient.background
            
            TrendingCollectionView(
                movies: viewModel.movies,
                imageConfig: viewModel.imageConfig,
                onMovieSelected: { movie in
                    router.navigate(to: .movieDetail(movie))
                },
                onReachCell: { movie in
                    Task { await viewModel.loadMoreIfNeeded(currentItem: movie) }
                }
            )

            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Trending")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.onAppear()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    NavigationStack {
        TrendingView()
            .environment(Router())
    }
}
