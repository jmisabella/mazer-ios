//
//  DeltaCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

extension String {
    func capitalizedFirstLetter() -> String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}

struct DeltaCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color
//    let grid: OpaquePointer? // TODO: not sure if we'll need this... finish integrating FFI render functionality into this file

    /// Snap a value to the nearest device‐pixel.
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

            // 2) Stroke the walls
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
//             }

//                mazer_free_edge_pairs(edgePairs) // Free memory
//            }
            // Stroke walls using Rust FFI
            Path { p in
                // Convert cell.linked to UInt32 codes
                let linkedCodes: [UInt32] = cell.linked.compactMap { linkedDir in
//                    MazeDirection(rawValue: linkedDir.capitalizedFirstLetter())?.code
                    MazeDirection(rawValue: linkedDir)?.code

                }
                let orientationCode: UInt32 = cell.orientation.lowercased() == "normal" ? 0 : 1
                var linkedArray = linkedCodes
                let edgePairs = linkedArray.withUnsafeMutableBufferPointer { buffer in
                    mazer_delta_wall_segments(buffer.baseAddress, buffer.count, orientationCode)
                }
                guard edgePairs.ptr != nil else { return }
                let edges = UnsafeBufferPointer(start: edgePairs.ptr, count: edgePairs.len)
                for edge in edges {
                    p.move(to: points[Int(edge.first)])
                    p.addLine(to: points[Int(edge.second)])
                }
                mazer_free_edge_pairs(edgePairs) // Free memory
            }
            .stroke(Color.black, lineWidth: snap(cellStrokeWidth(for: cellSize, mazeType: .delta)))
        }
        .frame(width: snap(cellSize), height: snap(triangleHeight))
        .drawingGroup(opaque: true)
        .clipped(antialiased: false)
    }
}
