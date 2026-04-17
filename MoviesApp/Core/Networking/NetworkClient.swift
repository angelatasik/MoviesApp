//
//  NetworkClient.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

protocol NetworkClient {
    func fetch<T: Decodable>(_ endpoint: Requestable) async throws -> T
}
