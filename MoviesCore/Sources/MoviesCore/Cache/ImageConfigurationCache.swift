//
//  ImageConfigurationCache.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import Foundation

public protocol ImageConfigurationCaching {
    var configuration: ImageConfiguration? { get }
    func store(_ configuration: ImageConfiguration)
}

public final class ImageConfigurationCache: ImageConfigurationCaching {
    public private(set) var configuration: ImageConfiguration?

    public init() {}

    public func store(_ configuration: ImageConfiguration) {
        self.configuration = configuration
    }
}
