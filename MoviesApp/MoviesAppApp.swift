//
//  MoviesAppApp.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 15.4.26.
//

import SwiftUI
import SwiftData

@main
struct MoviesAppApp: App {
    @State private var router = Router()
    @State private var favoritesManager: FavoritesManager
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            let container = try ModelContainer(for: FavoriteMovie.self)
            self.modelContainer = container
            self._favoritesManager = State(
                initialValue: FavoritesManager(modelContext: container.mainContext)
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                TrendingView()
                    .navigationDestination(for: AppRoute.self) { route in
                        route.destination
                    }
            }
            .environment(router)
            .environment(favoritesManager)
            .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
