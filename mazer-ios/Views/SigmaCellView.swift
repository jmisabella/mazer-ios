//
//  HexCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/22/25.
//

import SwiftUI

struct SigmaCellView: View {
    // MARK: – Public API
    let allCells: [MazeCell] // TODO: REMOVE DEBUG LINE
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color


    // MARK: – Private storage
    private let cellMap: [Coordinates: MazeCell]

    // MARK: – Init
    init(
        allCells: [MazeCell], // TODO: REMOVE DEBUG LINE
        cell: MazeCell,
        cellSize: CGFloat,
        showSolution: Bool,
        showHeatMap: Bool,
        selectedPalette: HeatMapPalette,
        maxDistance: Int,
        isRevealedSolution: Bool,
        defaultBackgroundColor: Color
    ) {
        self.cell = cell
        self.allCells = allCells
        self.cellSize = cellSize
        self.showSolution = showSolution
        self.showHeatMap = showHeatMap
        self.selectedPalette = selectedPalette
        self.maxDistance = maxDistance
        self.isRevealedSolution = isRevealedSolution
        self.defaultBackgroundColor = defaultBackgroundColor

        // build fast lookup by coordinate
        var m = [Coordinates: MazeCell]()
        for c in allCells {
            m[Coordinates(x: c.x, y: c.y)] = c
        }
        self.cellMap = m
    }

    // MARK: – Geometry helpers
    private var width: CGFloat { cellSize * 2 }
    private var height: CGFloat { cellSize * sqrt(3) }
    private func snap(_ x: CGFloat) -> CGFloat {
        let scale = UIScreen.main.scale
        return (x * scale).rounded() / scale
    }
    private var points: [CGPoint] {
        let s = cellSize, h = sqrt(3) * s
        return [
            CGPoint(x: snap(s * 0.5), y: snap(0)),    // top-left
            CGPoint(x: snap(s * 1.5), y: snap(0)),    // top-right
            CGPoint(x: snap(2 * s),    y: snap(h/2)), // mid-right
            CGPoint(x: snap(s * 1.5), y: snap(h)),    // bottom-right
            CGPoint(x: snap(s * 0.5), y: snap(h)),    // bottom-left
            CGPoint(x: snap(0),        y: snap(h/2)) // mid-left
        ]
    }

    // MARK: – Body
    var body: some View {
        ZStack {
            // 1) fill
            Path { p in
                p.addLines(points); p.closeSubpath()
            }
            .fill(cellBackgroundColor(
                for: cell,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                maxDistance: maxDistance,
                selectedPalette: selectedPalette,
                isRevealedSolution: isRevealedSolution,
                defaultBackground: defaultBackgroundColor
            ))

            // 2) walls with mismatch‐skip
            Path { p in
                for dir in HexDirection.allCases {
                    let linked       = cell.linked.contains(dir.rawValue)
                    // check neighbor’s reciprocal link:
                    let coord        = Coordinates(
                        x: cell.x + dir.delta.dq,
                        y: cell.y + dir.delta.dr
                    )
                    let neighborLink = cellMap[coord]?
                        .linked.contains(dir.opposite.rawValue) ?? false

                    // if this is a phantom‐mismatch, skip drawing:
//                    if linked != neighborLink {
//                        continue
//                    }

                    // otherwise draw the wall if not linked:
                    if !linked {
                        let (i, j) = dir.vertexIndices
                        p.move(to: points[i])
                        p.addLine(to: points[j])
                    }
                }
            }
            .stroke(
                Color.black,
                lineWidth: snap(cellStrokeWidth(for: cellSize, mazeType: .sigma))
            )
        }
        .frame(width: width, height: height)
        .compositingGroup()
        .drawingGroup(opaque: true, colorMode: .linear)
        .clipped(antialiased: false)
    }
}

////struct SigmaCellView: View {
////    let cell: MazeCell
////    let cellSize: CGFloat           // side length of the hexagon
////    let showSolution: Bool
////    let showHeatMap: Bool
////    let selectedPalette: HeatMapPalette
////    let maxDistance: Int
////    let isRevealedSolution: Bool
////
////    // flat-topped hexagon metrics
////    private var width: CGFloat { cellSize * 2 }
////    private var height: CGFloat { cellSize * sqrt(3) }
////
////    // the six vertices, clockwise from “top-left corner”
////    private var points: [CGPoint] {
////        let s = cellSize
////        let h = s * sqrt(3)
////        return [
////            .init(x:  s * 0.5, y: 0     ), // top-left
////            .init(x:  s * 1.5, y: 0     ), // top-right
////            .init(x:2 * s,      y: h/2 ), // mid-right
////            .init(x:  s * 1.5, y: h     ), // bottom-right
////            .init(x:  s * 0.5, y: h     ), // bottom-left
////            .init(x:   0    , y: h/2   )  // mid-left
////        ]
////    }
////
////    var body: some View {
////        ZStack {
////            // 1) fill
////            Path { p in
////                p.addLines(points)
////                p.closeSubpath()
////            }
////            .fill(
////                cellBackgroundColor(
////                    for: cell,
////                    showSolution: showSolution,
////                    showHeatMap: showHeatMap,
////                    maxDistance: maxDistance,
////                    selectedPalette: selectedPalette,
////                    isRevealedSolution: isRevealedSolution
////                )
////            )
////
////            // 2) walls
////            Path { p in
////                let ds = cell.linked
////                let pts = points
////
////                if !ds.contains("Up")          { p.move(to: pts[0]); p.addLine(to: pts[1]) }
////                if !ds.contains("UpperRight")  { p.move(to: pts[1]); p.addLine(to: pts[2]) }
////                if !ds.contains("LowerRight")  { p.move(to: pts[2]); p.addLine(to: pts[3]) }
////                if !ds.contains("Down")        { p.move(to: pts[3]); p.addLine(to: pts[4]) }
////                if !ds.contains("LowerLeft")   { p.move(to: pts[4]); p.addLine(to: pts[5]) }
////                if !ds.contains("UpperLeft")   { p.move(to: pts[5]); p.addLine(to: pts[0]) }
////            }
////            .stroke(Color.black, lineWidth: snapStroke())
////        }
////        .frame(width: snapFrame(width), height: snapFrame(height))
////    }
////
////    // Snap stroke width to device-pixel grid
////    private func snapStroke() -> CGFloat {
////        let w = cellStrokeWidth(for: cellSize)
////        let scale = UIScreen.main.scale
////        return (w * scale).rounded() / scale
////    }
////
////    // Snap overall frame dimensions too
////    private func snapFrame(_ x: CGFloat) -> CGFloat {
////        let scale = UIScreen.main.scale
////        return (x * scale).rounded() / scale
////    }
////}
//
//
//struct SigmaCellView: View {
//    let allCells: [MazeCell]  /// TODO: REMOVE THIS DEBUG LINE
//    let cell: MazeCell
//    let cellSize: CGFloat  // side length of the hexagon
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let selectedPalette: HeatMapPalette
//    let maxDistance: Int
//    let isRevealedSolution: Bool
//
//    // flat-topped hexagon metrics
//    private var width: CGFloat { cellSize * 2 }
//    private var height: CGFloat { cellSize * sqrt(3) }
//
//    // the six vertices, clockwise from “top-left corner”:
//    private var points: [CGPoint] {
//        let s = cellSize
//        let h = sqrt(3) * s
//        return [
//            CGPoint(x: snap(s * 0.5), y: snap(0)),  // top-left
//            CGPoint(x: snap(s * 1.5), y: snap(0)),  // top-right
//            CGPoint(x: snap(2 * s), y: snap(h / 2)),  // mid-right
//            CGPoint(x: snap(s * 1.5), y: snap(h)),  // bottom-right
//            CGPoint(x: snap(s * 0.5), y: snap(h)),  // bottom-left
//            CGPoint(x: snap(0), y: snap(h / 2)),  // mid-left
//        ]
//    }
//    //    private var points: [CGPoint] {
//    //        let s = cellSize
//    //        let h = sqrt(3) * s
//    //        return [
//    //            CGPoint(x:  s * 0.5, y:   0    ), // top-left
//    //            CGPoint(x:  s * 1.5, y:   0    ), // top-right
//    //            CGPoint(x:2 * s,      y: h / 2 ), // mid-right
//    //            CGPoint(x:  s * 1.5, y:   h    ), // bottom-right
//    //            CGPoint(x:  s * 0.5, y:   h    ), // bottom-left
//    //            CGPoint(x:   0   ,   y: h / 2 )  // mid-left
//    //        ]
//    //    }
//
//    /// Snap to nearest device pixel
//    private func snap(_ x: CGFloat) -> CGFloat {
//        let scale = UIScreen.main.scale
//        return (x * scale).rounded() / scale
//    }
//
//    var body: some View {
//        ZStack {
//            // 1) fill
//            Path { p in
//                p.addLines(points)
//                p.closeSubpath()
//            }
//            .fill(
//                cellBackgroundColor(
//                    for: cell,
//                    showSolution: showSolution,
//                    showHeatMap: showHeatMap,
//                    maxDistance: maxDistance,
//                    selectedPalette: selectedPalette,
//                    isRevealedSolution: isRevealedSolution
//                ))
//
//            // 2) walls
//            Path { p in
//                let dirs = cell.linked
//                // force the start cell to only be open “Up”
//                //                let dirs = cell.isStart
//                //                ? ["Up"]
//                //                : cell.linked
//
//                let pts = points
//
//                for dir in HexDirection.allCases {
//                    if !cell.linked.contains(dir.rawValue) {
//                      let (i, j) = dir.vertexIndices
//                      p.move(to: points[i])
//                      p.addLine(to: points[j])
//                    }
//                  }
//            }
//            //            .stroke(Color.black, lineWidth: cellStrokeWidth(for: cellSize))
//            .stroke(
//                Color.black,
//                lineWidth: snap(cellStrokeWidth(for: cellSize))
//            )
//        }
//        .frame(width: width, height: height)
//        .compositingGroup()
//        .drawingGroup(opaque: true, colorMode: .linear)
//    }
//}
