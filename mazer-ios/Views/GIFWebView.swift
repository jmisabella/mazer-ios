//
//  GIFWebView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/7/25.
//

import SwiftUI
import WebKit

struct GIFWebView: UIViewRepresentable {
    let gifName: String // Name of GIF in asset catalog (without .gif extension)

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        loadGIF(into: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed unless gifName changes
    }

    private func loadGIF(into webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif") else {
            print("GIF file \(gifName).gif not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url)
        } catch {
            print("Error loading GIF: \(error)")
        }
    }
}
