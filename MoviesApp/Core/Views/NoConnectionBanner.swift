//
//  NoConnectionStatusView.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import SwiftUI

struct NoConnectionStatusView: View {
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: AppIcon.wifiSlash)
                .font(AppTypography.small)
                .foregroundStyle(AppColor.primaryText)
            
            Text(Strings.Network.noConnection)
                .font(AppTypography.smallMedium)
                .foregroundStyle(AppColor.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.small)
        .background(Color.red.opacity(0.85))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
