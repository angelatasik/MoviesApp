//
//  TrendingLayout.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import UIKit

enum TrendingLayout {
    
    // Target width for each poster — content-driven, not device-driven
    private static let idealItemWidth: CGFloat = 180
    
    // Aspect ratio for movie posters (2:3 standard)
    private static let posterAspectRatio: CGFloat = 1.5
    
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let containerWidth = environment.container.contentSize.width
            
            // Calculate columns dynamically based on ideal item width
            // e.g., if container is 800pt wide and ideal item is 180pt → ~4 columns
            let columns = max(2, Int(containerWidth / idealItemWidth))
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .estimated(containerWidth / CGFloat(columns) * posterAspectRatio)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(containerWidth / CGFloat(columns) * posterAspectRatio)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(Spacing.medium)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Spacing.extraLarge
            section.contentInsets = NSDirectionalEdgeInsets(
                top: Spacing.medium,
                leading: Spacing.medium,
                bottom: Spacing.medium,
                trailing: Spacing.medium
            )
            return section
        }
    }
}
