//
//  HexCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/22/25.
//

import SwiftUI

struct SigmaCellView: View {
    let cell: MazeCell
    let cellMap: [Coordinates: MazeCell]
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color
    let grid: OpaquePointer?

    // Cache a unit hexagon
    private static let unitPoints: [CGPoint] = {
        let s: CGFloat = 1
        let h = sqrt(3) * s
        return [
            .init(x: 0.5, y: 0),
            .init(x: 1.5, y: 0),
            .init(x: 2,   y: h/2),
            .init(x: 1.5, y: h),
            .init(x: 0.5, y: h),
            .init(x: 0,   y: h/2)
        ]
    }()

    // Pre‐scaled points
    private var scaledPoints: [CGPoint] {
        SigmaCellView.unitPoints.map { .init(x: $0.x * cellSize, y: $0.y * cellSize) }
    }

    // Single stroke width calculation
    private var strokeWidth: CGFloat {
        let raw = cellStrokeWidth(for: cellSize, mazeType: .sigma)
        let scale = UIScreen.main.scale
        return (raw * scale).rounded() / scale
    }

    // Background fill color
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

    var body: some View {
        ZStack {
            // 1) fill
            Path { p in
                p.addLines(scaledPoints)
                p.closeSubpath()
            }
            .fill(fillColor)

            Path { p in
                guard let grid = grid else { return }
                let coords = FFICoordinates(x: cell.x, y: cell.y)
                let edgePairs = mazer_sigma_wall_segments(grid, coords)
                let edges = UnsafeBufferPointer(start: edgePairs.ptr, count: edgePairs.len)
                for edge in edges {
                    p.move(to: scaledPoints[Int(edge.first)])
                    p.addLine(to: scaledPoints[Int(edge.second)])
                }
                mazer_free_edge_pairs(edgePairs)
            }
            .stroke(Color.black, lineWidth: strokeWidth)
        }
        .frame(
            width: cellSize * 2,
            height: sqrt(3) * cellSize,
            alignment: .center
        )
    }
}
