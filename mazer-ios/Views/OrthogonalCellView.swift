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
            .stroke(Color.black, lineWidth: 1)
            .frame(width: size, height: size)
        }
    }

    private var backgroundColor: Color {
        if showHeatMap {
            let normalized = min(max(Double(cell.distance) / 50.0, 0.0), 1.0)
            return Color(red: 1.0, green: 1.0 - normalized, blue: 0.5)
        } else if showSolution && cell.onSolutionPath {
            return .green
        } else {
            return .white
        }
    }
}
