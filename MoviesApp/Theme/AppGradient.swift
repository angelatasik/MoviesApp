//
//  AppGradient.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 17.4.26.
//

import SwiftUI

enum AppGradient {
    static var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),   // dark navy top
                Color(red: 0.15, green: 0.08, blue: 0.25),   // purple middle
                Color(red: 0.25, green: 0.08, blue: 0.18)    // dark red bottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
