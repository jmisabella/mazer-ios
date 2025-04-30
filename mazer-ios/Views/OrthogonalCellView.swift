//
//  OrthogonalCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

struct OrthogonalCellView: View {
    let cell: MazeCell
    let size: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellBackgroundColor(
                                    for: cell,
                                    showSolution: showSolution,
                                    showHeatMap: showHeatMap,
                                    maxDistance: maxDistance,
                                    selectedPalette: selectedPalette,
                                    isRevealedSolution: isRevealedSolution
                                ))
                .frame(width: size, height: size)

            Path { path in
                let topLeft = CGPoint(x: 0, y: 0)
                let topRight = CGPoint(x: size, y: 0)
                let bottomLeft = CGPoint(x: 0, y: size)
                let bottomRight = CGPoint(x: size, y: size)

                if !cell.linked.contains("Up") {
                    path.move(to: topLeft)
                    path.addLine(to: topRight)
                }
                if !cell.linked.contains("Right") {
                    path.move(to: topRight)
                    path.addLine(to: bottomRight)
                }
                if !cell.linked.contains("Down") {
                    path.move(to: bottomRight)
                    path.addLine(to: bottomLeft)
                }
                if !cell.linked.contains("Left") {
                    path.move(to: bottomLeft)
                    path.addLine(to: topLeft)
                }
            }
            .stroke(Color.black, lineWidth: cellStrokeWidth(for: size, mazeType: .orthogonal))
            .frame(width: size, height: size)
            .clipped()

        }
    }

}
