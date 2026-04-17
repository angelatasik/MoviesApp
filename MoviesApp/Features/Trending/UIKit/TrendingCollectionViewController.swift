//
//  TrendingCollectionViewController.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import UIKit

final class TrendingCollectionViewController: UIViewController {

    // MARK: - Properties

    private var collectionView: UICollectionView!
    private var movies: [Movie] = []
    private var imageConfig: ImageConfiguration?

    var onMovieSelected: ((Movie) -> Void)?
    var onReachCell: ((Movie) -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    // MARK: - Public API

    func update(movies: [Movie], imageConfig: ImageConfiguration?) {
        self.movies = movies
        self.imageConfig = imageConfig
        collectionView.reloadData()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = TrendingLayout.make()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        view.backgroundColor = .clear
        collectionView.register(
            TrendingCollectionViewCell.self,
            forCellWithReuseIdentifier: TrendingCollectionViewCell.reuseID
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
}

// MARK: - UICollectionViewDataSource

extension TrendingCollectionViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        movies.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrendingCollectionViewCell.reuseID,
            for: indexPath
        ) as? TrendingCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: movies[indexPath.item], imageConfig: imageConfig)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TrendingCollectionViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        onMovieSelected?(movies[indexPath.item])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        onReachCell?(movies[indexPath.item])
    }
}
