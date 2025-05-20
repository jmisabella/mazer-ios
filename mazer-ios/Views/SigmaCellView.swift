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

            // walls
//            Path { p in
//                let q = cell.x
//                let r = cell.y
//                let isOddCol = (q & 1) == 1
//
//                for dir in HexDirection.allCases {
//                    // 1) compute this cell’s link and true neighbor coords in odd-q
//                    let linked = cell.linked.contains(dir.rawValue)
//                    let (dq, dr) = dir.offsetDelta(isOddColumn: isOddCol)
//                    let neighborCoord = Coordinates(x: q + dq, y: r + dr)
//                    guard let neighbor = cellMap[neighborCoord] else {
//                        continue
//                    }
//
//                    // 2) YOUR rule ONLY: if *both* cells are onSolutionPath
//                    //    AND their distance differs by exactly 1, skip that wall
//                    if cell.onSolutionPath
//                       && neighbor.onSolutionPath
//                       && abs(cell.distance - neighbor.distance) == 1
//                    {
//                        continue
//                    }
//
//                    // 3) otherwise draw the wall whenever this cell isn’t linked out
//                    if !linked {
//                        let (i, j) = dir.vertexIndices
//                        p.move(to: scaledPoints[i])
//                        p.addLine(to: scaledPoints[j])
//                    }
//                }
//            }
            Path { p in
                let q = cell.x
                let r = cell.y
                let isOddCol = (q & 1) == 1

                for dir in HexDirection.allCases {
                    // 1) figure out this cell's link
                    let linked = cell.linked.contains(dir.rawValue)

                    // 2) locate the neighbor using your odd-q math
                    let (dq, dr) = dir.offsetDelta(isOddColumn: isOddCol)
                    let neighborCoord = Coordinates(x: q + dq, y: r + dr)
                    guard let neighbor = cellMap[neighborCoord] else { continue }

                    // 3) FIRST: if both are on the solution path AND
                    //    their distance differs by exactly 1, skip that wall
                    if cell.onSolutionPath
                       && neighbor.onSolutionPath
                       && abs(cell.distance - neighbor.distance) == 1
                    {
                        continue
                    }

                    // 4) compute the neighbor’s idea of a link in the opposite direction
                    let neighborLink = neighbor
                        .linked
                        .contains(dir.opposite.rawValue)

                    // 5) ONLY draw a wall when *neither* side thinks there’s a passage
                    if !(linked || neighborLink) {
                        let (i, j) = dir.vertexIndices
                        p.move(to: scaledPoints[i])
                        p.addLine(to: scaledPoints[j])
                    }
                }
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
