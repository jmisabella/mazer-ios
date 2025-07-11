
import SwiftUI

struct SigmaCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color
    let totalRows: Int

    @Environment(\.cellMap) private var cellMap: [Coordinates: MazeCell]

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

    private var scaledPoints: [CGPoint] {
        SigmaCellView.unitPoints.map { .init(x: $0.x * cellSize, y: $0.y * cellSize) }
    }

    private var adjustedPoints: [CGPoint] {
        let overlap: CGFloat = 1.0 / UIScreen.main.scale
        let C = CGPoint(x: cellSize, y: (sqrt(3)/2) * cellSize)
        return scaledPoints.map { P in
            let dx = P.x - C.x
            let dy = P.y - C.y
            let factor = overlap / cellSize
            return CGPoint(x: P.x + factor * dx, y: P.y + factor * dy)
        }
    }

    private var strokeWidth: CGFloat {
        wallStrokeWidth(for: .sigma, cellSize: cellSize)
    }
    
    private var fillColor: Color {
        cellBackgroundColor(
            for: cell,
            showSolution: showSolution,
            showHeatMap: showHeatMap,
            maxDistance: maxDistance,
            selectedPalette: selectedPalette,
            isRevealedSolution: isRevealedSolution,
            defaultBackground: defaultBackgroundColor,
            totalRows: totalRows
        )
    }

    var body: some View {
        ZStack {
            Path { p in
                p.addLines(adjustedPoints)
                p.closeSubpath()
            }
            .fill(fillColor)

            Path { p in
                let q = cell.x
                let r = cell.y
                let isOddCol = (q & 1) == 1

                for dir in HexDirection.allCases {
                    let linked = cell.linked.contains(dir.rawValue)
                    let (dq, dr) = dir.offsetDelta(isOddColumn: isOddCol)
                    let neighborCoord = Coordinates(x: q + dq, y: r + dr)
                    guard let neighbor = cellMap[neighborCoord] else { continue }

                    if cell.onSolutionPath
                       && neighbor.onSolutionPath
                       && abs(cell.distance - neighbor.distance) == 1
                    {
                        continue
                    }

                    let neighborLink = neighbor.linked.contains(dir.opposite.rawValue)

                    if !(linked || neighborLink) {
                        let (i, j) = dir.vertexIndices
                        p.move(to: adjustedPoints[i])
                        p.addLine(to: adjustedPoints[j])
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
////
////  HexCellView.swift
////  mazer-ios
////
////  Created by Jeffrey Isabella on 4/22/25.
////
//
//import SwiftUI
//
//struct SigmaCellView: View {
//    let cell: MazeCell
//    let cellSize: CGFloat
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let selectedPalette: HeatMapPalette
//    let maxDistance: Int
//    let isRevealedSolution: Bool
//    let defaultBackgroundColor: Color
//
//    @Environment(\.cellMap) private var cellMap: [Coordinates: MazeCell]
//
//    private static let unitPoints: [CGPoint] = {
//        let s: CGFloat = 1
//        let h = sqrt(3) * s
//        return [
//            .init(x: 0.5, y: 0),
//            .init(x: 1.5, y: 0),
//            .init(x: 2,   y: h/2),
//            .init(x: 1.5, y: h),
//            .init(x: 0.5, y: h),
//            .init(x: 0,   y: h/2)
//        ]
//    }()
//
//    private var scaledPoints: [CGPoint] {
//        SigmaCellView.unitPoints.map { .init(x: $0.x * cellSize, y: $0.y * cellSize) }
//    }
//
//    private var adjustedPoints: [CGPoint] {
//        let overlap: CGFloat = 1.0 / UIScreen.main.scale
//        let C = CGPoint(x: cellSize, y: (sqrt(3)/2) * cellSize)
//        return scaledPoints.map { P in
//            let dx = P.x - C.x
//            let dy = P.y - C.y
//            let factor = overlap / cellSize
//            return CGPoint(x: P.x + factor * dx, y: P.y + factor * dy)
//        }
//    }
//
////    private var strokeWidth: CGFloat {
////        let raw = cellSize / 6
////        let scale = UIScreen.main.scale
////        return (raw * scale).rounded() / scale
////    }
//    private var strokeWidth: CGFloat {
//        wallStrokeWidth(for: .sigma, cellSize: cellSize)
//    }
//    
//    private var fillColor: Color {
//        cellBackgroundColor(
//            for: cell,
//            showSolution: showSolution,
//            showHeatMap: showHeatMap,
//            maxDistance: maxDistance,
//            selectedPalette: selectedPalette,
//            isRevealedSolution: isRevealedSolution,
//            defaultBackground: defaultBackgroundColor
//        )
//    }
//
//    var body: some View {
//        ZStack {
//            Path { p in
//                p.addLines(adjustedPoints)
//                p.closeSubpath()
//            }
//            .fill(fillColor)
//
//            Path { p in
//                let q = cell.x
//                let r = cell.y
//                let isOddCol = (q & 1) == 1
//
//                for dir in HexDirection.allCases {
//                    let linked = cell.linked.contains(dir.rawValue)
//                    let (dq, dr) = dir.offsetDelta(isOddColumn: isOddCol)
//                    let neighborCoord = Coordinates(x: q + dq, y: r + dr)
//                    guard let neighbor = cellMap[neighborCoord] else { continue }
//
//                    if cell.onSolutionPath
//                       && neighbor.onSolutionPath
//                       && abs(cell.distance - neighbor.distance) == 1
//                    {
//                        continue
//                    }
//
//                    let neighborLink = neighbor.linked.contains(dir.opposite.rawValue)
//
//                    if !(linked || neighborLink) {
//                        let (i, j) = dir.vertexIndices
//                        p.move(to: adjustedPoints[i])
//                        p.addLine(to: adjustedPoints[j])
//                    }
//                }
//            }
//            .stroke(Color.black, lineWidth: strokeWidth)
//        }
//        .frame(
//            width: cellSize * 2,
//            height: sqrt(3) * cellSize,
//            alignment: .center
//        )
//    }
//}
//
