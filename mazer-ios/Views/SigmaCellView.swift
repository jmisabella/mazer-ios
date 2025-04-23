//
//  HexCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/22/25.
//

import SwiftUI

struct SigmaCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat           // side length of the hexagon
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool

    // flat-topped hexagon metrics
    private var width: CGFloat { cellSize * 2 }
    private var height: CGFloat { cellSize * sqrt(3) }

    // the six vertices, clockwise from “top-left corner”:
    private var points: [CGPoint] {
        let s = cellSize
        let h = sqrt(3) * s
        return [
            CGPoint(x:  s * 0.5, y:   0    ), // top-left
            CGPoint(x:  s * 1.5, y:   0    ), // top-right
            CGPoint(x:2 * s,      y: h / 2 ), // mid-right
            CGPoint(x:  s * 1.5, y:   h    ), // bottom-right
            CGPoint(x:  s * 0.5, y:   h    ), // bottom-left
            CGPoint(x:   0   ,   y: h / 2 )  // mid-left
        ]
    }

    var body: some View {
        ZStack {
            // 1) fill
            Path { p in
                p.addLines(points)
                p.closeSubpath()
            }
            .fill(cellBackgroundColor(
                for: cell,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                maxDistance: maxDistance,
                selectedPalette: selectedPalette,
                isRevealedSolution: isRevealedSolution
            ))

            // 2) walls
            Path { p in
                let dirs = cell.linked
                let pts = points

                if !dirs.contains("Up") {
                    p.move(to: pts[0]); p.addLine(to: pts[1])
                }
                if !dirs.contains("UpperRight") {
                    p.move(to: pts[1]); p.addLine(to: pts[2])
                }
                if !dirs.contains("LowerRight") {
                    p.move(to: pts[2]); p.addLine(to: pts[3])
                }
                if !dirs.contains("Down") {
                    p.move(to: pts[3]); p.addLine(to: pts[4])
                }
                if !dirs.contains("LowerLeft") {
                    p.move(to: pts[4]); p.addLine(to: pts[5])
                }
                if !dirs.contains("UpperLeft") {
                    p.move(to: pts[5]); p.addLine(to: pts[0])
                }
            }
            .stroke(Color.black, lineWidth: cellStrokeWidth(for: cellSize))
        }
        .frame(width: width, height: height)
    }
}
