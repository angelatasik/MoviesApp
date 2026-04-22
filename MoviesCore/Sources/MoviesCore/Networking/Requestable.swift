//
//  Requestable.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

public protocol Requestable {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
}

public extension Requestable {
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
}
