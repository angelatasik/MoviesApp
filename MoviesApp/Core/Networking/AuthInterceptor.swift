//
//  AuthInterceptor.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

struct AuthInterceptor: RequestInterceptor {
    private let token: String

    init(token: String) {
        self.token = token
    }

    func intercept(_ request: URLRequest) -> URLRequest {
        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
