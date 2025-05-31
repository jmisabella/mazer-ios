//
//  GIFView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 5/30/25.
//

import SwiftUI
import UIKit
import ImageIO

struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Load the GIF and set it to the image view
        if let animatedImage = loadGIF(named: gifName) {
            imageView.image = animatedImage
        }
        
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // No updates needed for static GIF
    }
    
    private func loadGIF(named name: String) -> UIImage? {
        // Locate the GIF file in the bundle
        guard let gifURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let source = CGImageSourceCreateWithURL(gifURL as CFURL, nil) else {
            print("Failed to load GIF: \(name).gif")
            return nil
        }
        
        // Get the frame count
        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else {
            print("No frames found in GIF: \(name).gif")
            return nil
        }
        
        // Extract frames and durations
        var images: [UIImage] = []
        var totalDuration: Double = 0
        
        for i in 0..<frameCount {
            // Get the CGImage for the frame
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            // Get the frame duration (default to 0.1s if not specified)
            let duration = frameDuration(at: i, source: source)
            totalDuration += duration
            
            // Convert CGImage to UIImage
            let uiImage = UIImage(cgImage: cgImage)
            images.append(uiImage)
        }
        
        // Create the animated UIImage
        guard !images.isEmpty else {
            print("No valid frames extracted from GIF: \(name).gif")
            return nil
        }
        
        return UIImage.animatedImage(with: images, duration: totalDuration)
    }
    
    private func frameDuration(at index: Int, source: CGImageSource) -> Double {
        // Get frame properties
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
            return 0.1 // Default duration if properties are unavailable
        }
        
        // Try to get unclamped delay time, fall back to delay time
        if let delay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double, delay > 0 {
            return delay
        } else if let delay = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double, delay > 0 {
            return delay
        }
        
        return 0.1 // Default duration
    }
}
