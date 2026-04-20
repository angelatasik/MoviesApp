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
    @State private var networkMonitor = AppDependencies.shared.networkMonitor
    
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
            VStack(spacing: 0) {
                // Banner at the very top, pushes content down when visible
                if !networkMonitor.isConnected {
                    NoConnectionStatusView()
                }
                
                NavigationStack(path: $router.path) {
                    TrendingView()
                        .navigationDestination(for: AppRoute.self) { route in
                            route.destination
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
            .environment(router)
            .environment(favoritesManager)
            .environment(networkMonitor)
            .preferredColorScheme(.dark)
            
        }
        .modelContainer(modelContainer)
    }
}
