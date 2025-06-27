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

    // 45°-rotated square unit points (top, right, bottom, left)
    private static let unitPoints: [CGPoint] = [
        .init(x: 0.5, y: 0),    // top
        .init(x: 1.0, y: 0.5),  // right
        .init(x: 0.5, y: 1.0),  // bottom
        .init(x: 0.0, y: 0.5)   // left
    ]

    private var strokeWidth: CGFloat {
        cellSize * 0.05
    }

    var body: some View {
        // diagonal of square = side * √2
        let box = cellSize * CGFloat(2).squareRoot()
        // map unitPoints to actual coordinates
        let pts = Self.unitPoints.map { CGPoint(x: $0.x * box, y: $0.y * box) }

        ZStack {
            // Fill the diamond
            Path { path in
                path.move(to: pts[0])
                for p in pts.dropFirst() { path.addLine(to: p) }
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

            // Draw walls only where there is no link
            Path { path in
                if !cell.linked.contains("UpperRight") {
                    path.move(to: pts[0])
                    path.addLine(to: pts[1])
                }
                if !cell.linked.contains("LowerRight") {
                    path.move(to: pts[1])
                    path.addLine(to: pts[2])
                }
                if !cell.linked.contains("LowerLeft") {
                    path.move(to: pts[2])
                    path.addLine(to: pts[3])
                }
                if !cell.linked.contains("UpperLeft") {
                    path.move(to: pts[3])
                    path.addLine(to: pts[0])
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
////    private static let unitPoints: [CGPoint] = [
////        .init(x: 0, y: 0),                    // Bottom
////        .init(x: 1, y: 0),                    // Right
////        .init(x: 1.5, y: sqrt(3)/2),          // Top
////        .init(x: 0.5, y: sqrt(3)/2)           // Left
////    ]
//    // 45°-rotated square:
//    private static let unitPoints: [CGPoint] = [
//        .init(x: 0.5, y: 0),    // top
//        .init(x: 1.0, y: 0.5),  // right
//        .init(x: 0.5, y: 1.0),  // bottom
//        .init(x: 0.0, y: 0.5)   // left
//    ]
//
//    private var points: [CGPoint] {
//        Self.unitPoints.map { .init(x: $0.x * cellSize, y: $0.y * cellSize) }
//    }
//
//    private var strokeWidth: CGFloat {
//        cellSize * 0.05
//    }
//    
//    var body: some View {
//            // box = diagonal-width of your square
//            let box = cellSize * CGFloat(2).squareRoot()
//            let pts = Self.unitPoints.map { CGPoint(x: $0.x * box, y: $0.y * box) }
//
//            ZStack {
//                Path { path in
//                    path.move(to: pts[0])
//                    for p in pts.dropFirst() { path.addLine(to: p) }
//                    path.closeSubpath()
//                }
//                .fill(cellBackgroundColor(
//                    for: cell,
//                    showSolution: showSolution,
//                    showHeatMap: showHeatMap,
//                    maxDistance: maxDistance,
//                    selectedPalette: selectedPalette,
//                    isRevealedSolution: isRevealedSolution,
//                    defaultBackground: defaultBackgroundColor
//                ))
//                Path { path in
//                    path.move(to: pts[0])
//                    for p in pts.dropFirst() { path.addLine(to: p) }
//                    path.closeSubpath()
//                }
//                .stroke(lineWidth: strokeWidth)
//            }
//            .frame(width: box, height: box)
//        }
//
////    var body: some View {
////        ZStack {
////            // Draw the rhombus
////            Path { p in
////                p.move(to: points[0])
////                p.addLine(to: points[1])
////                p.addLine(to: points[2])
////                p.addLine(to: points[3])
////                p.closeSubpath()
////            }
////            .fill(cellBackgroundColor(
////                for: cell,
////                showSolution: showSolution,
////                showHeatMap: showHeatMap,
////                maxDistance: maxDistance,
////                selectedPalette: selectedPalette,
////                isRevealedSolution: isRevealedSolution,
////                defaultBackground: defaultBackgroundColor
////            ))
////
////            // Draw walls for unlinked directions
////            Path { p in
////                if !cell.linked.contains("UpperRight") {
////                    p.move(to: points[1])  // Right
////                    p.addLine(to: points[2])  // Top
////                }
////                if !cell.linked.contains("LowerRight") {
////                    p.move(to: points[0])  // Bottom
////                    p.addLine(to: points[1])  // Right
////                }
////                if !cell.linked.contains("LowerLeft") {
////                    p.move(to: points[0])  // Bottom
////                    p.addLine(to: points[3])  // Left
////                }
////                if !cell.linked.contains("UpperLeft") {
////                    p.move(to: points[2])  // Top
////                    p.addLine(to: points[3])  // Left
////                }
////            }
////            .stroke(Color.black, lineWidth: strokeWidth)
////        }
////    }
//}
