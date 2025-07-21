//
//  LoadingOverlayView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/7/25.
//

import SwiftUI

struct LoadingOverlayView: View {
    let algorithm: MazeAlgorithm
    let colorScheme: ColorScheme
    let fontScale: CGFloat

    var body: some View {
        ZStack {
            // Semi-transparent gray overlay for the entire screen
            Color.gray.opacity(0.5)
                .ignoresSafeArea()

            // Content with opaque box
            VStack(spacing: 24) {
                let darkModeGIFs = ["loading-snakes-blue", "loading-snakes-purple"]
                let gifName = colorScheme == .dark ? darkModeGIFs.randomElement() ?? "loading-snakes-blue" : "loading-snakes-red"
                GIFWebView(gifName: gifName)
                    .frame(width: 120, height: 120)
                    .offset(y: 25)
                Text("Generating Maze")
                    .font(.headline)
                    .scaleEffect(fontScale)
                Text(algorithm.displayName)
                    .font(.subheadline)
                    .scaleEffect(fontScale)
                Text(algorithm.description)
                    .font(.caption)
                    .scaleEffect(fontScale)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true) // Ensure text wraps without truncation
                    .padding(.horizontal, 16) // Inner padding for text readability
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.vertical, 32) // Increased vertical padding for taller box
            .padding(.horizontal, 32) // Consistent horizontal padding
            .frame(minWidth: 300, maxWidth: 360, minHeight: 300) // Explicit min height to ensure taller box
            .background(
                Rectangle()
                    .fill(colorScheme == .dark ? Color.black : CellColors.offWhite)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            )
            .padding(.horizontal, 16) // Outer padding to prevent edge clipping
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center in screen
        }
    }
}
