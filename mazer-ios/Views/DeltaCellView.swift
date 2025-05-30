//
//  DeltaCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

struct DeltaCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color

    /// Snap a value to the nearest device-pixel.
    private func snap(_ x: CGFloat) -> CGFloat {
        let scale = UIScreen.main.scale
        return (x * scale).rounded() / scale
    }

    /// Height of an equilateral triangle of side `cellSize`.
    private var triangleHeight: CGFloat {
        cellSize * sqrt(3) / 2
    }

    /// The three vertices, **all snapped**.
    private var points: [CGPoint] {
        let h = triangleHeight
        let overlap: CGFloat = 1.0 / UIScreen.main.scale // 1 pixel overlap, adjusted for screen scale
        if cell.orientation.lowercased() == "normal" {
            return [
                CGPoint(x: snap(cellSize/2), y: snap(0) - overlap),
                CGPoint(x: snap(0) - overlap, y: snap(h) + overlap),
                CGPoint(x: snap(cellSize) + overlap, y: snap(h) + overlap),
            ]
        } else {
            return [
                CGPoint(x: snap(0) - overlap, y: snap(0) - overlap),
                CGPoint(x: snap(cellSize) + overlap, y: snap(0) - overlap),
                CGPoint(x: snap(cellSize/2), y: snap(h) + overlap),
            ]
        }
    }

    /// Extend the line endpoints by a specified length.
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
        ZStack {
            // 1) Fill the triangle
            Path { p in
                let pts = points
                p.move(to: pts[0])
                p.addLine(to: pts[1])
                p.addLine(to: pts[2])
                p.closeSubpath()
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

            // 2) Stroke the walls with extended lines
            Path { p in
                let pts = points
                let extensionLength: CGFloat = 0.5 / UIScreen.main.scale
                if cell.orientation.lowercased() == "normal" {
                    if !cell.linked.contains("UpperLeft") {
                        let (newStart, newEnd) = extendLine(from: pts[0], to: pts[1], by: extensionLength)
                        p.move(to: newStart)
                        p.addLine(to: newEnd)
                    }
                    if !cell.linked.contains("UpperRight") {
                        let (newStart, newEnd) = extendLine(from: pts[0], to: pts[2], by: extensionLength)
                        p.move(to: newStart)
                        p.addLine(to: newEnd)
                    }
                    if !cell.linked.contains("Down") {
                        let (newStart, newEnd) = extendLine(from: pts[1], to: pts[2], by: extensionLength)
                        p.move(to: newStart)
                        p.addLine(to: newEnd)
                    }
                } else {
                    if !cell.linked.contains("Up") {
                        let (newStart, newEnd) = extendLine(from: pts[0], to: pts[1], by: extensionLength)
                        p.move(to: newStart)
                        p.addLine(to: newEnd)
                    }
                    if !cell.linked.contains("LowerLeft") {
                        let (newStart, newEnd) = extendLine(from: pts[0], to: pts[2], by: extensionLength)
                        p.move(to: newStart)
                        p.addLine(to: newEnd)
                    }
                    if !cell.linked.contains("LowerRight") {
                        let (newStart, newEnd) = extendLine(from: pts[1], to: pts[2], by: extensionLength)
                        p.move(to: newStart)
                        p.addLine(to: newEnd)
                    }
                }
            }
            .stroke(Color.black, lineWidth: snap(cellStrokeWidth(for: cellSize, mazeType: .delta) * 1.15))
        }
        .frame(width: snap(cellSize), height: snap(triangleHeight))
        .drawingGroup(opaque: true) // Keep this for rendering optimization
        // Remove .clipped(antialiased: false) here
    }
}

//import SwiftUI
//struct DeltaCellView: View {
//    let cell: MazeCell
//    let cellSize: CGFloat
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let selectedPalette: HeatMapPalette
//    let maxDistance: Int
//    let isRevealedSolution: Bool
//    let defaultBackgroundColor: Color
//
//    /// Snap a value to the nearest device‐pixel.
//    private func snap(_ x: CGFloat) -> CGFloat {
//        let scale = UIScreen.main.scale
//        return (x * scale).rounded() / scale
//    }
//
//    /// Height of an equilateral triangle of side `cellSize`.
//    private var triangleHeight: CGFloat {
//        cellSize * sqrt(3) / 2
//    }
//
//    /// The three vertices, **all snapped**.
//    private var points: [CGPoint] {
//        let h = triangleHeight
//        let overlap: CGFloat = 1.0 / UIScreen.main.scale // 1 pixel overlap, adjusted for screen scale
//        if cell.orientation.lowercased() == "normal" {
//            return [
//                CGPoint(x: snap(cellSize/2), y: snap(0) - overlap),
//                CGPoint(x: snap(0) - overlap, y: snap(h) + overlap),
//                CGPoint(x: snap(cellSize) + overlap, y: snap(h) + overlap),
//            ]
//        } else {
//            return [
//                CGPoint(x: snap(0) - overlap, y: snap(0) - overlap),
//                CGPoint(x: snap(cellSize) + overlap, y: snap(0) - overlap),
//                CGPoint(x: snap(cellSize/2), y: snap(h) + overlap),
//            ]
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            // 1) Fill the triangle
//            Path { p in
//                let pts = points
//                p.move(to: pts[0])
//                p.addLine(to: pts[1])
//                p.addLine(to: pts[2])
//                p.closeSubpath()
//            }
//            .fill(cellBackgroundColor(
//                for: cell,
//                showSolution: showSolution,
//                showHeatMap: showHeatMap,
//                maxDistance: maxDistance,
//                selectedPalette: selectedPalette,
//                isRevealedSolution: isRevealedSolution,
//                defaultBackground: defaultBackgroundColor
//            ))
//
//            // 2) Stroke the walls
//            Path { p in
//                let pts = points
//                if cell.orientation.lowercased() == "normal" {
//                    if !cell.linked.contains("UpperLeft")  { p.move(to: pts[0]); p.addLine(to: pts[1]) }
//                    if !cell.linked.contains("UpperRight") { p.move(to: pts[0]); p.addLine(to: pts[2]) }
//                    if !cell.linked.contains("Down")       { p.move(to: pts[1]); p.addLine(to: pts[2]) }
//                } else {
//                    if !cell.linked.contains("Up")         { p.move(to: pts[0]); p.addLine(to: pts[1]) }
//                    if !cell.linked.contains("LowerLeft")  { p.move(to: pts[0]); p.addLine(to: pts[2]) }
//                    if !cell.linked.contains("LowerRight") { p.move(to: pts[1]); p.addLine(to: pts[2]) }
//                }
//            }
//            .stroke(Color.black, lineWidth: snap(cellStrokeWidth(for: cellSize, mazeType: .delta)))
//        }
//        .frame(width: snap(cellSize), height: snap(triangleHeight))
//        .drawingGroup(opaque: true)
//        .clipped(antialiased: false)
//    }
//}
