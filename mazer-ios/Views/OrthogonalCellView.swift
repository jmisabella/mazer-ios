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

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(width: size, height: size)

            Path { path in
                let topLeft = CGPoint(x: 0, y: 0)
                let topRight = CGPoint(x: size, y: 0)
                let bottomLeft = CGPoint(x: 0, y: size)
                let bottomRight = CGPoint(x: size, y: size)

                if !cell.linked.contains("North") {
                    path.move(to: topLeft)
                    path.addLine(to: topRight)
                }
                if !cell.linked.contains("East") {
                    path.move(to: topRight)
                    path.addLine(to: bottomRight)
                }
                if !cell.linked.contains("South") {
                    path.move(to: bottomRight)
                    path.addLine(to: bottomLeft)
                }
                if !cell.linked.contains("West") {
                    path.move(to: bottomLeft)
                    path.addLine(to: topLeft)
                }
            }
//            .stroke(Color.black, lineWidth: 1)
            .stroke(Color.black, lineWidth: strokeWidth(for: size))
            .frame(width: size, height: size)
            .clipped()
            
            ////  uncomment for debugging purposes with the heat map feature
//            Text("\(cell.distance)")
//                        .font(.caption2)
//                        .foregroundColor(.black)
        }
    }

    private var backgroundColor: Color {
        if showHeatMap && maxDistance > 0 {
            let index = min(9, (cell.distance * 10) / maxDistance)
            return selectedPalette.shades[index].asColor
        } else if showSolution && cell.onSolutionPath {
            return .green
        } else {
            return .white
        }
    }
    
    private func strokeWidth(for size: CGFloat) -> CGFloat {
        switch size {
        case ..<9:
            return 1.0 // Tight line for small cells (6pt)
        case ..<14:
            return 1.5 // Medium
        default:
            return 2.5 // Large
        }
    }

}
