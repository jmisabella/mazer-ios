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
            Color.gray.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                GIFWebView(gifName: "loadingMaze")
                    .frame(width: 100, height: 100)
                Text("Generating Maze")
                    .font(.headline)
                    .scaleEffect(fontScale)
                Text(algorithm.rawValue)
                    .font(.subheadline)
                    .scaleEffect(fontScale)
                Text(algorithm.description)
                    .font(.caption)
                    .scaleEffect(fontScale)
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}

//
//struct LoadingOverlayView: View {
//    let algorithm: MazeAlgorithm
//    let colorScheme: ColorScheme
//    let fontScale: CGFloat
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                GIFWebView(gifName: "loadingMaze")
//                    .frame(width: 100, height: 100)
//                    .padding()
//
//                Text("Generating Maze")
//                    .font(.system(size: 16 * fontScale, weight: .bold))
//                    .foregroundColor(colorScheme == .dark ? .white : .black)
//
//                Text("Algorithm: \(algorithm.rawValue.capitalized)")
//                    .font(.system(size: 14 * fontScale))
//                    .foregroundColor(colorScheme == .dark ? Color(hex: "B3B3B3") : Color.lightModeSecondary)
//
//                Text(algorithm.description)
//                    .font(.system(size: 12 * fontScale))
//                    .foregroundColor(colorScheme == .dark ? .secondary : Color.lightModeSecondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.9))
//            )
//            .padding(.horizontal, 20)
//        }
//    }
//}
