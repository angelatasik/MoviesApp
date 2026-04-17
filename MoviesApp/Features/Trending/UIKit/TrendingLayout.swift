//
//  TrendingLayout.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import UIKit

enum TrendingLayout {
    
    private static let wideLayoutMinWidth: CGFloat = 600
    private static let wideLayoutColumns = 3
    private static let standardColumns = 2
    private static let estimatedItemHeight: CGFloat = 300
    
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let width = environment.container.contentSize.width
            let columns = width > wideLayoutMinWidth ? wideLayoutColumns : standardColumns

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .estimated(estimatedItemHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedItemHeight)
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
