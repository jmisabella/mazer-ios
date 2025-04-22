//
//  ConfettiView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/21/25.
//

import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: UIScreen.main.bounds)

    let emitter = CAEmitterLayer()
    emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
    emitter.emitterShape    = .line
    emitter.emitterSize     = CGSize(width: view.bounds.width, height: 1)

    // use a few system colors
    let colors: [UIColor] = [
      .systemRed, .systemBlue, .systemGreen,
      .systemOrange, .systemPurple
    ]

    emitter.emitterCells = colors.map { color in
      let cell = CAEmitterCell()
      cell.birthRate     = 4
      cell.lifetime      = 6.0
      cell.velocity      = 350
      cell.velocityRange = 80
      cell.emissionRange = .pi / 4
      cell.spin          = 3.5
      cell.spinRange     = 1
      cell.scale         = 0.6
      cell.scaleRange    = 0.3
      cell.color         = color.cgColor
      // use a simple circle as the confetti “shape”
      cell.contents      = UIImage(systemName: "circle.fill")?.cgImage
      return cell
    }

    view.layer.addSublayer(emitter)

    // stop emission after 2s
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      emitter.birthRate = 0
      // remove after remaining particles die out
      DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
        emitter.removeFromSuperlayer()
      }
    }

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {}
}
