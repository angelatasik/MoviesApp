//
//  PagedResponse.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

struct PagedResponse<T: Decodable>: Decodable, Sendable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int
}
