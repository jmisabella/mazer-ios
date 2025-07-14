//
//  GIFWebView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/7/25.
//

import SwiftUI
import WebKit

struct GIFWebView: UIViewRepresentable {
    let gifName: String // Name of data set in Assets.xcassets (e.g., "loadingMaze")

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        loadGIF(into: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func loadGIF(into webView: WKWebView) {
        guard let asset = NSDataAsset(name: gifName) else {
            print("Failed to load data asset '\(gifName)' from Assets.xcassets")
            return
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("\(gifName).gif")
        
        do {
            try asset.data.write(to: tempFileURL)
            webView.loadFileURL(tempFileURL, allowingReadAccessTo: tempFileURL)
        } catch {
            print("Error loading GIF into WKWebView: \(error)")
        }
    }
}
