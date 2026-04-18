//
//  SearchView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 18.4.26.
//

import SwiftUI
import Kingfisher

struct SearchView: View {

    @State private var viewModel: SearchViewModel
    @Environment(Router.self) private var router
    @FocusState private var isSearchFocused: Bool

    private enum Layout {
        static let posterWidth: CGFloat = 60
        static let posterHeight: CGFloat = 92
        static let searchBarHeight: CGFloat = 44
    }

    init() {
        _viewModel = State(
            initialValue: SearchViewModel(
                repository: AppDependencies.shared.movieRepository,
                imageCache: AppDependencies.shared.imageConfigurationCache
            )
        )
    }

    var body: some View {
        ZStack {
            AppGradient.background

            VStack(spacing: Spacing.medium) {
                searchBar
                segmentedControl
                contentView
            }
            .padding(.top, Spacing.medium)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: AppIcon.back)
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColor.primaryText)
                        .padding(Spacing.compact)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text(Strings.Search.title)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColor.primaryText)
            }
        }
        .onAppear {
            isSearchFocused = true
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: AppIcon.search)
                .foregroundStyle(AppColor.tertiaryText)

            TextField("", text: Binding(
                get: { viewModel.query },
                set: { viewModel.onQueryChange($0) }
            ), prompt: Text(Strings.Search.placeholder).foregroundStyle(AppColor.tertiaryText))
                .foregroundStyle(AppColor.primaryText)
                .focused($isSearchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.onQueryChange("")
                } label: {
                    Image(systemName: AppIcon.close)
                        .foregroundStyle(AppColor.tertiaryText)
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
        .frame(height: Layout.searchBarHeight)
        .background(AppColor.surfaceOverlay, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, Spacing.large)
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        Picker("", selection: Binding(
            get: { viewModel.searchType },
            set: { viewModel.onSearchTypeChange($0) }
        )) {
            ForEach(SearchViewModel.SearchType.allCases) { type in
                Text(type.title).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Spacing.large)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
                .tint(AppColor.primaryText)
            Spacer()
        } else if viewModel.query.isEmpty {
            emptyStateView(
                systemImage: AppIcon.search,
                message: Strings.Search.startSearching
            )
        } else if viewModel.results.isEmpty {
            emptyStateView(
                systemImage: AppIcon.noResults,
                message: Strings.Search.noResults
            )
        } else {
            resultsListView
        }
    }

    private func emptyStateView(systemImage: String, message: String) -> some View {
        VStack(spacing: Spacing.medium) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(AppColor.tertiaryText)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.tertiaryText)
            Spacer()
        }
    }

    private var resultsListView: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.medium) {
                ForEach(viewModel.results) { result in
                    resultRow(result)
                        .onAppear {
                            Task { await viewModel.loadMoreIfNeeded(currentItem: result) }
                        }
                }
            }
            .padding(.horizontal, Spacing.large)
        }
    }

    private func resultRow(_ result: SearchViewModel.SearchResult) -> some View {
        Button {
            if case .movie(let movie) = result {
                router.navigate(to: .movieDetail(movie))
            }
            // TV show navigation can be added later
        } label: {
            HStack(spacing: Spacing.medium) {
                posterImage(for: result)

                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(result.title)
                        .font(AppTypography.bodySemibold)
                        .foregroundStyle(AppColor.primaryText)
                        .lineLimit(1)

                    if let year = DateFormatting.yearString(from: result.date) {
                        Text(year)
                            .font(AppTypography.small)
                            .foregroundStyle(AppColor.tertiaryText)
                    }

                    Text(result.overview)
                        .font(AppTypography.small)
                        .foregroundStyle(AppColor.secondaryText)
                        .lineLimit(2)
                }

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func posterImage(for result: SearchViewModel.SearchResult) -> some View {
        if let path = result.posterPath,
           let url = viewModel.imageConfig?.posterURL(path: path, width: Layout.posterWidth) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: Layout.posterWidth, height: Layout.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColor.placeholderFill)
                .frame(width: Layout.posterWidth, height: Layout.posterHeight)
        }
    }

}

#Preview {
    NavigationStack {
        SearchView()
            .environment(Router())
    }
}
