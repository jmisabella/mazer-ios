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

            // Content with opaque horizontal bar
            VStack(spacing: 20) {
                GIFWebView(gifName: "loadingMaze")
                    .frame(width: 100, height: 100)
                Text("Generating Maze")
                    .font(.headline)
                    .scaleEffect(fontScale)
                Text(algorithm.rawValue.capitalized)
                    .font(.subheadline)
                    .scaleEffect(fontScale)
                Text(algorithm.description)
                    .font(.caption)
                    .scaleEffect(fontScale)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.horizontal, 20) // Horizontal padding for the bar
            .padding(.vertical, 16)   // Vertical padding for the bar
            .background(
                Rectangle()
                    .fill(colorScheme == .dark ? Color.black : Color.offWhite)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            )
            .padding(.horizontal, 20) // Extra padding to prevent edge clipping
        }
    }
}

//import SwiftUI
//
//struct LoadingOverlayView: View {
//    let algorithm: MazeAlgorithm
//    let colorScheme: ColorScheme
//    let fontScale: CGFloat
//
//    var body: some View {
//        ZStack {
//            Color.gray.opacity(0.5)
//                .ignoresSafeArea()
//            VStack(spacing: 20) {
//                GIFWebView(gifName: "loadingMaze")
//                    .frame(width: 100, height: 100)
//                Text("Generating Maze")
//                    .font(.headline)
//                    .scaleEffect(fontScale)
//                Text(algorithm.rawValue)
//                    .font(.subheadline)
//                    .scaleEffect(fontScale)
//                Text(algorithm.description)
//                    .font(.caption)
//                    .scaleEffect(fontScale)
//            }
//            .foregroundColor(colorScheme == .dark ? .white : .black)
//        }
//    }
//}
