//
//  SparkleView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 5/16/25.
//

import SwiftUI
import AudioToolbox
import UIKit  // for UIFeedbackGenerator

struct Sparkle: Identifiable {
  let id = UUID()
  var x: Double, y: Double
  var size: Double
  var symbol: String
  var color: Color
  var opacity: Double = 0
  var scale: CGFloat = 0.1
}

struct SparkleView: View {
  @State private var sparkles: [Sparkle] = []
  let count: Int
  let totalDuration: Double
  let symbols = ["sparkles","star.fill","circle.fill"]
  let colors: [Color] = [.yellow,.pink,.mint,.orange]

  init(count: Int = 60, totalDuration: Double = 3.0) {
    self.count = count
    self.totalDuration = totalDuration
  }

  var body: some View {
    GeometryReader { geo in
      ZStack {
        ForEach(sparkles) { sparkle in
            Image(systemName: sparkle.symbol)
                .foregroundColor(sparkle.color)
                .font(.system(size: sparkle.size))
                .opacity(sparkle.opacity)
                .scaleEffect(sparkle.scale)
                .position(
                  x: sparkle.x * geo.size.width,
                  y: sparkle.y * geo.size.height
                )
        }
      }
      .ignoresSafeArea()
      .onAppear { launchSparkles() }
    }
  }

  private func launchSparkles() {
    // 2) Calculate per‐sparkle launch delay so that the last one fires near totalDuration * 0.5
    let stagger = (totalDuration * 0.5) / Double(count)

      sparkles = (0..<count).map { _ in
        Sparkle(
          x: Double.random(in: 0...1),
          y: Double.random(in: 0...1),
          size: Double.random(in: 20...50),
          symbol: symbols.randomElement()!,      // pick one of your SF symbols
          color:  colors.randomElement()!        // pick one of your colors
        )
      }

    for i in sparkles.indices {
      let delay = Double(i) * stagger
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        // 3) Stretch out the fade durations to each occupy ~25% of totalDuration
        let fadeInDur  = totalDuration * 0.12
        let fadeOutDur = totalDuration * 0.12
        let visibleDur = totalDuration * 0.5

        withAnimation(.easeOut(duration: fadeInDur)) {
          sparkles[i].opacity = 1
          sparkles[i].scale   = 1
        }
        withAnimation(.easeIn(duration: fadeOutDur).delay(visibleDur)) {
          sparkles[i].opacity = 0
        }
      }
    }

    // 4) And only clean up after the full totalDuration + a bit of buffer
    DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 0.5) {
      sparkles.removeAll()
    }
  }
}
