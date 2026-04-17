//
//  DetailView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI
import Kingfisher

struct DetailView: View {

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
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
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
                    .frame(width: width, height: 500)
                    .clipped()
                    .overlay(AppGradient.imageFadeToBottom)
            } else {
                Color.black.opacity(0.3)
            }
        }
        .frame(height: 500)
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
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

            Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, -80) // pulls content over the fading backdrop
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.detail?.title ?? viewModel.movie.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 4)

            HStack(spacing: 10) {
                if let runtime = viewModel.detail?.runtime {
                    Text(runtimeString(from: runtime))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
                
                if let year = yearString(from: viewModel.detail?.releaseDate ?? viewModel.movie.releaseDate) {
                    circleSeparator
                    Text(year)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }
    
    private var circleSeparator: some View {
        Circle()
            .fill(.white.opacity(0.5))
            .frame(width: 3, height: 3)
    }

    private var ratingSection: some View {
        HStack(spacing: 8) {
            let rating = viewModel.detail?.voteAverage ?? viewModel.movie.voteAverage
            let stars = Int(rating / 2)

            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundStyle(.yellow)
            }

            Text(String(format: "%.1f", rating))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            Text("(\(viewModel.detail?.voteCount ?? viewModel.movie.voteCount) votes)")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func overviewSection(_ overview: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text(overview)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(4)
        }
    }

    private func castSection(_ cast: [CastMember]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(cast.prefix(15)) { member in
                        castMemberView(member)
                    }
                }
            }
        }
    }

    private func castMemberView(_ member: CastMember) -> some View {
        VStack(spacing: 6) {
            if let path = member.profilePath,
               let url = viewModel.imageConfig?.profileURL(path: path, width: 70) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white.opacity(0.5))
                    )
            }

            Text(member.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(width: 80)

            Text(member.character)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
                .frame(width: 80)
        }
    }

    private func genresSection(_ genres: [Genre]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Genres")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(genres) { genre in
                        Text(genre.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(.white.opacity(0.15))
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
