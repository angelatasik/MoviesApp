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
    }
    
    // MARK: - Subviews
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = CornerRadius.medium
        imageView.backgroundColor = .systemGray5
        return imageView
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
        let stack = UIStackView(arrangedSubviews: [posterImageView, titleLabel, overviewLabel])
        stack.axis = .vertical
        stack.spacing = Spacing.extraSmall
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterImageView.heightAnchor.constraint(
                equalTo: posterImageView.widthAnchor,
                multiplier: Layout.posterAspectRatio
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
