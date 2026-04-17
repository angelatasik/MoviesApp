//
//  ImageConfigurationCache.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import Foundation

protocol ImageConfigurationCaching {
    var configuration: ImageConfiguration? { get }
    func store(_ configuration: ImageConfiguration)
}

final class ImageConfigurationCache: ImageConfigurationCaching {
    private(set) var configuration: ImageConfiguration?

    func store(_ configuration: ImageConfiguration) {
        self.configuration = configuration
    }
}
