//
//  TrendingCollectionView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI
import MoviesCore

struct TrendingCollectionView: UIViewControllerRepresentable {

    let movies: [Movie]
    let imageConfig: ImageConfiguration?
    let onMovieSelected: (Movie) -> Void
    let onReachCell: (Movie) -> Void

    func makeUIViewController(context: Context) -> TrendingCollectionViewController {
        let viewController = TrendingCollectionViewController()
        viewController.onMovieSelected = onMovieSelected
        viewController.onReachCell = onReachCell
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: TrendingCollectionViewController,
        context: Context
    ) {
        uiViewController.update(movies: movies, imageConfig: imageConfig)
    }
}
