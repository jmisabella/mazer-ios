//
//  DeltaCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

struct DeltaCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat  // This represents the side length (base) of the triangle.
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool

    /// Compute the triangle height based on an equilateral triangle.
    var triangleHeight: CGFloat {
        cellSize * CGFloat(sqrt(3)) / 2.0
    }

    var body: some View {
        ZStack {
            // Draw the triangle background.
            Path { path in
                if cell.orientation.lowercased() == "normal" {
                    // Normal (pointing up)
                    let v1 = CGPoint(x: cellSize / 2, y: 0)
                    let v2 = CGPoint(x: 0, y: triangleHeight)
                    let v3 = CGPoint(x: cellSize, y: triangleHeight)
                    path.move(to: v1)
                    path.addLine(to: v2)
                    path.addLine(to: v3)
                    path.closeSubpath()
                } else {
                    // Inverted (pointing down)
                    let v1 = CGPoint(x: 0, y: 0)
                    let v2 = CGPoint(x: cellSize, y: 0)
                    let v3 = CGPoint(x: cellSize / 2, y: triangleHeight)
                    path.move(to: v1)
                    path.addLine(to: v2)
                    path.addLine(to: v3)
                    path.closeSubpath()
                }
            }
            .fill(cellBackgroundColor(
                for: cell,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                maxDistance: maxDistance,
                selectedPalette: selectedPalette,
                isRevealedSolution: isRevealedSolution
            ))
            
            // Draw the walls.
            Path { path in
                if cell.orientation.lowercased() == "normal" {
                    let v1 = CGPoint(x: cellSize / 2, y: 0)
                    let v2 = CGPoint(x: 0, y: triangleHeight)
                    let v3 = CGPoint(x: cellSize, y: triangleHeight)
                    
                    if !cell.linked.contains("UpperLeft") {
                        path.move(to: v1)
                        path.addLine(to: v2)
                    }
                    if !cell.linked.contains("UpperRight") {
                        path.move(to: v1)
                        path.addLine(to: v3)
                    }
                    if !cell.linked.contains("Down") {
                        path.move(to: v2)
                        path.addLine(to: v3)
                    }
                } else {
                    let v1 = CGPoint(x: 0, y: 0)
                    let v2 = CGPoint(x: cellSize, y: 0)
                    let v3 = CGPoint(x: cellSize / 2, y: triangleHeight)
                    
                    if !cell.linked.contains("Up") {
                        path.move(to: v1)
                        path.addLine(to: v2)
                    }
                    if !cell.linked.contains("LowerLeft") {
                        path.move(to: v1)
                        path.addLine(to: v3)
                    }
                    if !cell.linked.contains("LowerRight") {
                        path.move(to: v2)
                        path.addLine(to: v3)
                    }
                }
            }
            .stroke(Color.black, lineWidth: cellStrokeWidth(for: cellSize))
        }
        // Use a frame that exactly fits an equilateral triangle.
        .frame(width: cellSize, height: triangleHeight)
        .clipped()
    }
}
