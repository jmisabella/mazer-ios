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
//struct GIFWebView: UIViewRepresentable {
//    let gifName: String
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        if let url = Bundle.main.url(forResource: gifName, withExtension: "gif") {
//            let data = try? Data(contentsOf: url)
//            webView.load(data!, mimeType: "image/gif", characterEncodingName: "", baseURL: url.deletingLastPathComponent())
//        }
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {}
//}

//
//struct GIFWebView: UIViewRepresentable {
//    let gifName: String // Name of GIF in asset catalog (without .gif extension)
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.backgroundColor = .clear
//        webView.isOpaque = false
//        loadGIF(into: webView)
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // No updates needed unless gifName changes
//    }
//
//    private func loadGIF(into webView: WKWebView) {
//        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif") else {
//            print("GIF file \(gifName).gif not found in bundle")
//            return
//        }
//        do {
//            let data = try Data(contentsOf: url)
//            webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url)
//        } catch {
//            print("Error loading GIF: \(error)")
//        }
//    }
//}
