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
    
    // MARK: - Layout
    
    private enum Layout {
        static let posterAspectRatio: CGFloat = 1.4
        static let maxLines = 2
        static let titleFontSize: CGFloat = 18
        static let overviewFontSize: CGFloat = 14
        static let overviewTextOpacity: CGFloat = 0.5
        static let fallbackPosterWidth: CGFloat = 200
        static let placeholderIconOpacity: CGFloat = 0.3
        static let containerBackgroundOpacity: CGFloat = 0.08
    }
    
    // MARK: - Subviews

    private let posterContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = CornerRadius.medium
        view.backgroundColor = UIColor.white.withAlphaComponent(Layout.containerBackgroundOpacity)
        return view
    }()

    private let placeholderIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        let imageView = UIImageView(image: UIImage(systemName: AppIcon.filmPlaceholder, withConfiguration: config))
        imageView.tintColor = UIColor.white.withAlphaComponent(Layout.placeholderIconOpacity)
        imageView.contentMode = .center
        return imageView
    }()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.titleFontSize, weight: .semibold)
        label.numberOfLines = Layout.maxLines
        label.textColor = .white
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.overviewFontSize)
        label.textColor = UIColor.white.withAlphaComponent(Layout.overviewTextOpacity)
        label.numberOfLines = Layout.maxLines
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
        // Poster container holds placeholder + image + blur overlay
        posterContainer.addSubview(placeholderIcon)
        posterContainer.addSubview(posterImageView)
        posterContainer.addSubview(blurView)
        placeholderIcon.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            placeholderIcon.centerXAnchor.constraint(equalTo: posterContainer.centerXAnchor),
            placeholderIcon.centerYAnchor.constraint(equalTo: posterContainer.centerYAnchor),

            posterImageView.topAnchor.constraint(equalTo: posterContainer.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: posterContainer.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: posterContainer.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: posterContainer.bottomAnchor),
           
            blurView.topAnchor.constraint(equalTo: posterContainer.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: posterContainer.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: posterContainer.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: posterContainer.bottomAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [posterContainer, titleLabel, overviewLabel])
        stack.axis = .vertical
        stack.spacing = Spacing.extraSmall
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterContainer.heightAnchor.constraint(
                equalTo: posterContainer.widthAnchor,
                multiplier: Layout.posterAspectRatio
            )
        ])
    }
    
    // MARK: - Configure
    
    func configure(with movie: Movie, imageConfig: ImageConfiguration?) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        blurView.alpha = 1

        let posterWidth = bounds.width > 0 ? bounds.width : Layout.fallbackPosterWidth
        
        guard
            let imageConfig,
            let posterPath = movie.posterPath,
            let fullURL = imageConfig.posterURL(path: posterPath, width: posterWidth)
        else {
            posterImageView.image = nil
            blurView.alpha = 0
            return
        }

        let lowResURL = imageConfig.imageURL(path: posterPath, size: ImageSize.posterXSmall)

        // Load low-res first (blur stays visible), then full-res, then fade out blur
        posterImageView.kf.setImage(with: lowResURL) { [weak self] result in
            guard let self else { return }
            if case .failure = result {
                // Low-res failed — hide blur to show placeholder
                UIView.animate(withDuration: 0.3) { self.blurView.alpha = 0 }
                return
            }
            self.posterImageView.kf.setImage(with: fullURL) { [weak self] _ in
                UIView.animate(withDuration: 0.3) {
                    self?.blurView.alpha = 0
                }
            }
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        blurView.alpha = 1
        titleLabel.text = nil
        overviewLabel.text = nil
    }
}
