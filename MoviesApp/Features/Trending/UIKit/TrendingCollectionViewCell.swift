//
//  TrendingCollectionViewCell.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import UIKit
import Kingfisher

final class TrendingCollectionViewCell: UICollectionViewCell {

    static let reuseID = "TrendingCollectionViewCell"

    // MARK: - Subviews

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [posterImageView, titleLabel, overviewLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterImageView.heightAnchor.constraint(
                equalTo: posterImageView.widthAnchor,
                multiplier: 1.4
            )
        ])
    }

    // MARK: - Configure

    func configure(with movie: Movie, imageConfig: ImageConfiguration?) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview

        guard
            let imageConfig,
            let posterPath = movie.posterPath,
            let url = imageConfig.posterURL(path: posterPath, width: bounds.width)
        else {
            posterImageView.image = nil
            return
        }
        posterImageView.kf.setImage(with: url)
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        overviewLabel.text = nil
    }
}
