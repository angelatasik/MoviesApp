//
//  PagedResponse.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import Foundation

public struct PagedResponse<T: Codable & Sendable>: Codable, Sendable {
    public let page: Int
    public let results: [T]
    public let totalPages: Int
    public let totalResults: Int

    public init(page: Int, results: [T], totalPages: Int, totalResults: Int) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
}
