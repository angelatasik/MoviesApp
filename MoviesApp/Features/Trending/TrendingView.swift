//
//  TrendingView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI
import MoviesCore

struct TrendingView: View {

    @State private var viewModel: TrendingViewModel
    @Environment(Router.self) private var router

    init() {
        _viewModel = State(
            initialValue: TrendingViewModel(
                repository: AppDependencies.shared.movieRepository,
                imageCache: AppDependencies.shared.imageConfigurationCache,
                prefetcher: AppDependencies.shared.contentPrefetcher,
                networkMonitor: AppDependencies.shared.networkMonitor
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            // Left — heart icon (favorites)
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.navigate(to: .favorites) 
                } label: {
                    Image(systemName: AppIcon.heart)
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColor.primaryText)
                }
                .accessibilityIdentifier("favorites_button")
            }
            
            // Center — title
            ToolbarItem(placement: .principal) {
                Text(Strings.Trending.title)
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(
                        AppColor.primaryText
                    )
            }
            
            // Right — search icon
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .search)
                } label: {
                    Image(systemName: AppIcon.search)
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColor.primaryText)
                }
                .accessibilityIdentifier("search_button")
            }
        }
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
