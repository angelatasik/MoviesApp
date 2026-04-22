//
//  RequestInterceptor.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

public protocol RequestInterceptor: Sendable {
    func intercept(_ request: URLRequest) -> URLRequest
}
