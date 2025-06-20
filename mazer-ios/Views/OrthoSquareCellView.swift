//
//  OrthoSquareCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/19/25.
//

import SwiftUI
import Darwin

struct OrthoSquareCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color

    private var cx: CGFloat { cellSize / 2 }
    private var cy: CGFloat { cellSize / 2 }
    private var r: CGFloat { cellSize / 2 }

    private var points: [CGPoint] {
        if cell.isSquare {
            return [
                CGPoint(x: cx - r, y: cy - r),
                CGPoint(x: cx + r, y: cy - r),
                CGPoint(x: cx + r, y: cy + r),
                CGPoint(x: cx - r, y: cy + r)
            ]
        } else {
            var pts = [CGPoint]()
            for i in 0..<8 {
                let angle = (Double(i) * 45.0) * .pi / 180.0
                pts.append(CGPoint(x: cx + r * Darwin.cos(angle), y: cy + r * sin(angle)))
            }
            return pts
        }
    }

    private var wallSegments: [(Int, Int)] {
        if cell.isSquare {
            return [
                (0, 1), // up
                (1, 2), // right
                (2, 3), // down
                (3, 0)  // left
            ]
        } else {
            return [
                (7, 0), // up
                (0, 1), // upper right
                (1, 2), // right
                (2, 3), // lower right
                (3, 4), // down
                (4, 5), // lower left
                (5, 6), // left
                (6, 7)  // upper left
            ]
        }
    }

    private var directions: [String] {
        if cell.isSquare {
            return ["Up", "Right", "Down", "Left"]
        } else {
            return ["Up", "UpperRight", "Right", "LowerRight", "Down", "LowerLeft", "Left", "UpperLeft"]
        }
    }

    private var fillColor: Color {
        cellBackgroundColor(
            for: cell,
            showSolution: showSolution,
            showHeatMap: showHeatMap,
            maxDistance: maxDistance,
            selectedPalette: selectedPalette,
            isRevealedSolution: isRevealedSolution,
            defaultBackground: defaultBackgroundColor
        )
    }

    private var strokeWidth: CGFloat {
        let raw: CGFloat
        switch cellSize {
        case ..<18:
            raw = 3.0
        case 18..<24:
            raw = 3.5
        default:
            raw = 4.0
        }
        let scale = UIScreen.main.scale
        return (raw * scale).rounded() / scale
    }

    var body: some View {
        ZStack {
            Path { p in
                p.addLines(points)
                p.closeSubpath()
            }
            .fill(fillColor)

            Path { p in
                for (i, dir) in directions.enumerated() {
                    if !cell.linked.contains(dir) {
                        let (start, end) = wallSegments[i]
                        p.move(to: points[start])
                        p.addLine(to: points[end])
                    }
                }
            }
            .stroke(Color.black, lineWidth: strokeWidth)
        }
        .frame(width: cellSize, height: cellSize)
    }
}
