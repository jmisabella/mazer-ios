////
////  RhombilleCellView.swift
////  mazer-ios
////
////  Created by Jeffrey Isabella on 6/22/25.
////

import SwiftUI

struct RhombilleCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color

    private static let unitPoints: [CGPoint] = [
        .init(x: 0.5, y: 0),    // top
        .init(x: 1.0, y: 0.5),  // right
        .init(x: 0.5, y: 1.0),  // bottom
        .init(x: 0.0, y: 0.5)   // left
    ]

    private var strokeWidth: CGFloat {
        return wallStrokeWidth(for: .rhombille, cellSize: cellSize)
    }

    private func snap(_ x: CGFloat) -> CGFloat {
        let scale = UIScreen.main.scale
        return (x * scale).rounded() / scale
    }

    private func extendLine(from start: CGPoint, to end: CGPoint, by extensionLength: CGFloat) -> (CGPoint, CGPoint) {
        let direction = CGVector(dx: end.x - start.x, dy: end.y - start.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        let unitDirection = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        let extensionVector = CGVector(dx: unitDirection.dx * extensionLength, dy: unitDirection.dy * extensionLength)
        let newStart = CGPoint(x: start.x - extensionVector.dx, y: start.y - extensionVector.dy)
        let newEnd = CGPoint(x: end.x + extensionVector.dx, y: end.y + extensionVector.dy)
        return (newStart, newEnd)
    }

    var body: some View {
        let box = cellSize * CGFloat(2).squareRoot()
        let pts = Self.unitPoints.map { CGPoint(x: snap($0.x * box), y: snap($0.y * box)) }
        let overlap: CGFloat = 1.0 / UIScreen.main.scale
        let adjustedPts = [
            CGPoint(x: pts[0].x, y: pts[0].y - overlap), // top
            CGPoint(x: pts[1].x + overlap, y: pts[1].y), // right
            CGPoint(x: pts[2].x, y: pts[2].y + overlap), // bottom
            CGPoint(x: pts[3].x - overlap, y: pts[3].y)  // left
        ]

        ZStack {
            Path { path in
                path.move(to: adjustedPts[0])
                for p in adjustedPts.dropFirst() { path.addLine(to: p) }
                path.closeSubpath()
            }
            .fill(
                cellBackgroundColor(
                    for: cell,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    maxDistance: maxDistance,
                    selectedPalette: selectedPalette,
                    isRevealedSolution: isRevealedSolution,
                    defaultBackground: defaultBackgroundColor
                )
            )

            Path { path in
                let extensionLength: CGFloat = 0.5 / UIScreen.main.scale
                if !cell.linked.contains("UpperRight") {
                    let (newStart, newEnd) = extendLine(from: pts[0], to: pts[1], by: extensionLength)
                    path.move(to: newStart)
                    path.addLine(to: newEnd)
                }
                if !cell.linked.contains("LowerRight") {
                    let (newStart, newEnd) = extendLine(from: pts[1], to: pts[2], by: extensionLength)
                    path.move(to: newStart)
                    path.addLine(to: newEnd)
                }
                if !cell.linked.contains("LowerLeft") {
                    let (newStart, newEnd) = extendLine(from: pts[2], to: pts[3], by: extensionLength)
                    path.move(to: newStart)
                    path.addLine(to: newEnd)
                }
                if !cell.linked.contains("UpperLeft") {
                    let (newStart, newEnd) = extendLine(from: pts[3], to: pts[0], by: extensionLength)
                    path.move(to: newStart)
                    path.addLine(to: newEnd)
                }
            }
            .stroke(Color.black, lineWidth: strokeWidth)
        }
        .frame(width: box, height: box)
    }
}

//import SwiftUI
//
//struct RhombilleCellView: View {
//    let cell: MazeCell
//    let cellSize: CGFloat
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let selectedPalette: HeatMapPalette
//    let maxDistance: Int
//    let isRevealedSolution: Bool
//    let defaultBackgroundColor: Color
//
//    // 45°-rotated square unit points (top, right, bottom, left)
//    private static let unitPoints: [CGPoint] = [
//        .init(x: 0.5, y: 0),    // top
//        .init(x: 1.0, y: 0.5),  // right
//        .init(x: 0.5, y: 1.0),  // bottom
//        .init(x: 0.0, y: 0.5)   // left
//    ]
//
//    private var strokeWidth: CGFloat {
//        return wallStrokeWidth(for: .rhombille, cellSize: cellSize)
//    }
//
//    var body: some View {
//        // diagonal of square = side * √2
//        let box = cellSize * CGFloat(2).squareRoot()
//        // map unitPoints to actual coordinates
//        let pts = Self.unitPoints.map { CGPoint(x: $0.x * box, y: $0.y * box) }
//
//        ZStack {
//            // Fill the diamond
//            Path { path in
//                path.move(to: pts[0])
//                for p in pts.dropFirst() { path.addLine(to: p) }
//                path.closeSubpath()
//            }
//            .fill(
//                cellBackgroundColor(
//                    for: cell,
//                    showSolution: showSolution,
//                    showHeatMap: showHeatMap,
//                    maxDistance: maxDistance,
//                    selectedPalette: selectedPalette,
//                    isRevealedSolution: isRevealedSolution,
//                    defaultBackground: defaultBackgroundColor
//                )
//            )
//
//            // Draw walls only where there is no link
//            Path { path in
//                if !cell.linked.contains("UpperRight") {
//                    path.move(to: pts[0])
//                    path.addLine(to: pts[1])
//                }
//                if !cell.linked.contains("LowerRight") {
//                    path.move(to: pts[1])
//                    path.addLine(to: pts[2])
//                }
//                if !cell.linked.contains("LowerLeft") {
//                    path.move(to: pts[2])
//                    path.addLine(to: pts[3])
//                }
//                if !cell.linked.contains("UpperLeft") {
//                    path.move(to: pts[3])
//                    path.addLine(to: pts[0])
//                }
//            }
//            .stroke(Color.black, lineWidth: strokeWidth)
//        }
//        .frame(width: box, height: box)
//    }
//}
