//
//  ProgressiveImageView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import SwiftUI
import Kingfisher

/// Loads a low-res blurred image first, then swaps to the sharp full-res version.
struct ProgressiveImageView: View {

    let lowResURL: URL?
    let fullURL: URL?

    @State private var phase: LoadPhase = .loading

    private enum LoadPhase {
        case loading
        case lowRes
        case fullRes
    }

    var body: some View {
        ZStack {
            switch phase {
            case .loading:
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)

            case .lowRes:
                KFImage(lowResURL)
                    .resizable()
                    .blur(radius: 10)

            case .fullRes:
                KFImage(fullURL)
                    .resizable()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: phase)
        .task(id: fullURL) {
            await loadProgressive()
        }
    }

    private func loadProgressive() async {
        phase = .loading

        // Load low-res thumbnail
        if let lowResURL {
            let success = await prefetch(lowResURL)
            if success { phase = .lowRes }
        }

        // Load full-res
        if let fullURL {
            let success = await prefetch(fullURL)
            if success { phase = .fullRes }
        }
    }

    private func prefetch(_ url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                if case .success = result {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
