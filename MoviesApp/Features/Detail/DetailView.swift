//
//  DetailView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI
import Kingfisher

struct DetailView: View {
    
    private enum Layout {
        static let castItemSize: CGFloat = 80
        static let backdropHeight: CGFloat = 400
        static let contentOverlap: CGFloat = 80
        static let bottomSpacerMinLength: CGFloat = 40
        static let separatorSize: CGFloat = 4
        static let titleShadowRadius: CGFloat = 4
    }
    
    @State private var viewModel: DetailViewModel
    @Environment(Router.self) private var router
    
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
        ZStack(alignment: .top) {
            AppGradient.background
            
            ScrollView {
                VStack(spacing: 0) {
                    backdropSection
                    contentSection
                }
            }
            .ignoresSafeArea(edges: .top)
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
            await viewModel.onAppear()
        }
    }
    
    // MARK: - Backdrop
    
    private var backdropSection: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            if let backdropPath = viewModel.movie.backdropPath ?? viewModel.movie.posterPath,
               let url = viewModel.imageConfig?.backdropURL(path: backdropPath, width: width) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: Layout.backdropHeight)
                    .clipped()
                    .overlay(AppGradient.imageFadeToBottom)
            } else {
                AppColor.blackOpacity
            }
        }
        .frame(height: Layout.backdropHeight)
    }
    
    // MARK: - Content
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            headerSection
            ratingSection
            
            let overview = viewModel.detail?.overview ?? viewModel.movie.overview
            if !overview.isEmpty {
                overviewSection(overview)
            }
            
            if let credits = viewModel.credits, !credits.cast.isEmpty {
                castSection(credits.cast)
            }
            
            if let genres = viewModel.detail?.genres, !genres.isEmpty {
                genresSection(genres)
            }
            
            Spacer(minLength: Layout.bottomSpacerMinLength)
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, -Layout.contentOverlap) // pulls content over the fading backdrop
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(viewModel.detail?.title ?? viewModel.movie.title)
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColor.primaryText)
                .shadow(color: AppColor.blackOpacity, radius: Layout.titleShadowRadius)
            
            HStack(spacing: Spacing.compact) {
                if let runtime = viewModel.detail?.runtime {
                    Text(runtimeString(from: runtime))
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColor.secondaryText)
                }
                
                if let year = yearString(from: viewModel.detail?.releaseDate ?? viewModel.movie.releaseDate) {
                    circleSeparator
                    Text(year)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
        }
    }
    
    private var circleSeparator: some View {
        Circle()
            .fill(AppColor.mutedText)
            .frame(width: Layout.separatorSize, height: Layout.separatorSize)
    }
    
    private var ratingSection: some View {
        HStack(spacing: Spacing.small) {
            let rating = viewModel.detail?.voteAverage ?? viewModel.movie.voteAverage
            let stars = Int(rating / 2)
            
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < stars ? AppIcon.starFilled : AppIcon.starEmpty)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.accent)
            }
            
            Text(String(format: "%.1f", rating))
                .font(AppTypography.bodySemibold)
                .foregroundStyle(AppColor.primaryText)
            
            Text("(\(viewModel.detail?.voteCount ?? viewModel.movie.voteCount) \(Strings.Detail.votes)")
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
    
    // MARK: - Helpers
    
    private func yearString(from date: String?) -> String? {
        guard let date, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
    
    private func runtimeString(from minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours == 0 { return "\(mins)min" }
        return "\(hours)h \(mins)min"
    }
}

#Preview {
    NavigationStack {
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
    }
}
