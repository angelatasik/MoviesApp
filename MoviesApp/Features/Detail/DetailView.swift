//
//  DetailView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI
import Kingfisher
import SwiftData

struct DetailView: View {
    
    private enum Layout {
        static let castItemSize: CGFloat = 80
        static let backdropHeightRatio: CGFloat = 0.45
        static let backdropMaxHeight: CGFloat = 600
        static let contentWidthRatio: CGFloat = 0.9
        static let contentMaxWidth: CGFloat = 700
        static let contentOverlap: CGFloat = 80
        static let bottomSpacerMinLength: CGFloat = 40
        static let separatorSize: CGFloat = 4
        static let titleShadowRadius: CGFloat = 4
        static let heartIconSize: CGFloat = 22
    }
    
    @State private var viewModel: DetailViewModel
    @Environment(Router.self) private var router
    @Environment(FavoritesManager.self) private var favoritesManager
    
    init(movie: Movie) {
        _viewModel = State(
            initialValue: DetailViewModel(
                movie: movie,
                repository: AppDependencies.shared.movieRepository,
                imageCache: AppDependencies.shared.imageConfigurationCache
            )
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let backdropHeight = min(
                geometry.size.height * Layout.backdropHeightRatio,
                Layout.backdropMaxHeight
            )
            let contentMaxWidth = min(
                geometry.size.width * Layout.contentWidthRatio,
                Layout.contentMaxWidth
            )
            
            ZStack(alignment: .top) {
                AppGradient.background
                
                ScrollView {
                    VStack(spacing: 0) {
                        backdropSection(width: geometry.size.width, height: backdropHeight)
                        contentSection(maxWidth: contentMaxWidth)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .frame(maxWidth: .infinity)
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
        }
        .task {
            viewModel.loadFavoriteState(from: favoritesManager)
            await viewModel.onAppear()
        }
    }
    
    // MARK: - Backdrop
    
    private func backdropSection(width: CGFloat, height: CGFloat) -> some View {
        Group {
            if let backdropPath = viewModel.movie.backdropPath ?? viewModel.movie.posterPath,
               let url = viewModel.imageConfig?.backdropURL(path: backdropPath, width: width) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .overlay(AppGradient.imageFadeToBottom)
            } else {
                AppColor.blackOpacity
                    .frame(width: width, height: height)
            }
        }
    }
    
    // MARK: - Content
    
    private func contentSection(maxWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            headerSection
            ratingSection
            
            if !viewModel.overview.isEmpty {
                overviewSection(viewModel.overview)
            }
            
            if let credits = viewModel.credits, !credits.cast.isEmpty {
                castSection(credits.cast)
            }
            
            if let genres = viewModel.detail?.genres, !genres.isEmpty {
                genresSection(genres)
            }
            
            Spacer(minLength: Layout.bottomSpacerMinLength)
        }
        .frame(maxWidth: maxWidth)
        .padding(.horizontal, Spacing.large)
        .padding(.top, -Layout.contentOverlap) // pulls content over the fading backdrop
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text(viewModel.title)
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColor.primaryText)
                    .shadow(color: AppColor.blackOpacity, radius: Layout.titleShadowRadius)
                Spacer()
                favoriteButton
            }

            HStack(spacing: Spacing.compact) {
                if let runtimeText = viewModel.runtimeText {
                    Text(runtimeText)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColor.secondaryText)
                }

                if let year = viewModel.releaseYear {
                    circleSeparator
                    Text(year)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
        }
    }
    
    private var favoriteButton: some View {
        Button {
            viewModel.toggleFavorite(using: favoritesManager)
        } label: {
            Image(systemName: viewModel.favoriteIcon)
                .font(.system(size: Layout.heartIconSize))
                .foregroundStyle(viewModel.favoriteColor)
                .symbolEffect(.bounce, value: viewModel.isFavorite)
        }
    }
    
    private var circleSeparator: some View {
        Circle()
            .fill(AppColor.mutedText)
            .frame(width: Layout.separatorSize, height: Layout.separatorSize)
    }
    
    private var ratingSection: some View {
        HStack(spacing: Spacing.small) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < viewModel.starCount ? AppIcon.starFilled : AppIcon.starEmpty)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.accent)
            }

            Text(viewModel.formattedRating)
                .font(AppTypography.bodySemibold)
                .foregroundStyle(AppColor.primaryText)

            Text("(\(viewModel.voteCount) \(Strings.Detail.votes))")
                .font(AppTypography.smallMedium)
                .foregroundStyle(AppColor.secondaryText)
        }
    }
    
    private func overviewSection(_ overview: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(Strings.Detail.overview)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColor.primaryText)
            
            Text(overview)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.secondaryText)
                .lineSpacing(Spacing.extraSmall)
        }
    }
    
    private func castSection(_ cast: [CastMember]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(Strings.Detail.cast)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColor.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.balanced) {
                    ForEach(cast.prefix(15)) { member in
                        castMemberView(member)
                    }
                }
            }
        }
    }
    
    private func castMemberView(_ member: CastMember) -> some View {
        VStack(spacing: Spacing.narrow) {
            if let path = member.profilePath,
               let url = viewModel.imageConfig?.profileURL(path: path, width: Layout.castItemSize) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Layout.castItemSize, height: Layout.castItemSize)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(AppColor.placeholderFill)
                    .frame(width: Layout.castItemSize, height: Layout.castItemSize)
                    .overlay(
                        Image(systemName: AppIcon.personPlaceholder)
                            .foregroundStyle(AppColor.tertiaryText)
                    )
            }
            
            Text(member.name)
                .font(AppTypography.smallMedium)
                .foregroundStyle(AppColor.primaryText)
                .lineLimit(1)
            
            Text(member.character)
                .font(AppTypography.small)
                .foregroundStyle(AppColor.tertiaryText)
                .lineLimit(1)
        }
    }
    
    private func genresSection(_ genres: [Genre]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(Strings.Detail.genres)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColor.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.small) {
                    ForEach(genres) { genre in
                        Text(genre.name)
                            .font(AppTypography.smallMedium)
                            .foregroundStyle(AppColor.primaryText)
                            .padding(.horizontal, Spacing.balanced)
                            .padding(.vertical, Spacing.small)
                            .background(
                                Capsule().fill(AppColor.surfaceOverlay)
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: FavoriteMovie.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    return NavigationStack {
        DetailView(
            movie: Movie(
                id: 1,
                title: "Captain Marvel",
                overview: "Carol Danvers becomes one of the universe's most powerful heroes.",
                posterPath: nil,
                backdropPath: nil,
                voteAverage: 7.8,
                voteCount: 1234,
                releaseDate: "2019-03-06",
                genreIds: [28, 12],
                popularity: 123.4
            )
        )
        .environment(Router())
        .environment(FavoritesManager(modelContext: container.mainContext))
    }
}
