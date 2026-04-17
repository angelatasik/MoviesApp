//
//  MoviesAppApp.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 15.4.26.
//

import SwiftUI

@main
struct MoviesAppApp: App {
    @State private var router = Router()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                TrendingView()
                    .navigationDestination(for: AppRoute.self) { route in
                        route.destination
                    }
            }
            .environment(router)
            .preferredColorScheme(.dark)
        }
    }
}
