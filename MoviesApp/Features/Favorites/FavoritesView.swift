//
//  FavoritesView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 18.4.26.
//

import SwiftUI
import SwiftData
import Kingfisher

struct FavoritesView: View {
    
    @Environment(Router.self) private var router
    @Query(sort: \FavoriteMovie.addedDate, order: .reverse) private var favorites: [FavoriteMovie]
    @State private var imageConfig: ImageConfiguration?
    
    private enum Layout {
        static let posterWidth: CGFloat = 72
        static let posterHeight: CGFloat = 100
        static let posterCornerRadius: CGFloat = 8
    }
    
    var body: some View {
        ZStack {
            AppGradient.background
            
            if favorites.isEmpty {
                emptyStateView
            } else {
                favoritesList
            }
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
                Text(Strings.Favorites.title)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColor.primaryText)
            }
        }
        .task {
            imageConfig = AppDependencies.shared.imageConfigurationCache.configuration
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: AppIcon.heart)
                .font(.system(size: 48))
                .foregroundStyle(AppColor.tertiaryText)
            
            Text(Strings.Favorites.empty)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColor.primaryText)
        }
        .padding(.horizontal, Spacing.large)
    }
    
    // MARK: - List
    
    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.medium) {
                ForEach(favorites) { favorite in
                    favoriteRow(favorite)
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.top, Spacing.medium)
        }
    }
    
    private func favoriteRow(_ favorite: FavoriteMovie) -> some View {
        Button {
            router.navigate(to: .movieDetail(favorite.toMovie()))
        } label: {
            HStack(spacing: Spacing.medium) {
                posterImage(for: favorite)
                
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(favorite.title)
                        .font(AppTypography.bodySemibold)
                        .foregroundStyle(AppColor.primaryText)
                        .lineLimit(1)
                    
                    Text(favorite.overview)
                        .font(AppTypography.smallMedium)
                        .foregroundStyle(AppColor.tertiaryText)
                        .lineLimit(3)
                }
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func posterImage(for favorite: FavoriteMovie) -> some View {
        if let path = favorite.posterPath,
           let url = imageConfig?.posterURL(path: path, width: Layout.posterWidth) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: Layout.posterWidth, height: Layout.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: Layout.posterCornerRadius))
        } else {
            RoundedRectangle(cornerRadius: Layout.posterCornerRadius)
                .fill(AppColor.placeholderFill)
                .frame(width: Layout.posterWidth, height: Layout.posterHeight)
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
            .environment(Router())
    }
    .modelContainer(for: FavoriteMovie.self, inMemory: true)
}
