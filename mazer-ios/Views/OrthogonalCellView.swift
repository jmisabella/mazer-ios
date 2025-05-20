//
//  OrthogonalCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI


struct OrthogonalCellView: View {
    let cell: MazeCell
    //    let size: CGFloat
    let cellSize: CGFloat
    
    // pass through all the flags needed by `cellBackgroundColor`
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color
    
    //    let strokeWidth: CGFloat
    
    /// Snap any value to the pixel grid
      private func snap(_ x: CGFloat) -> CGFloat {
        let s = UIScreen.main.scale
        return (x * s).rounded() / s
      }
    
    private var size: CGFloat { snap(cellSize) }
    private var wallWidth: CGFloat {
        // pick a simple 1–2 pt wall
        let raw: CGFloat
//        print(cellSize)
        switch cellSize {
        case ..<18:
            raw = 1.85
        case 18..<24:
            raw = 2.25
        default:
            raw = 2.75
        }
        return (raw * UIScreen.main.scale).rounded() / UIScreen.main.scale
    }

    
    var body: some View {
        // 1) the full cell background
        Rectangle()
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
            .frame(width: size, height: size)
        
        // 2) horizontal walls
        // one single overlay that stacks vertical _then_ horizontal
            .overlay(
                ZStack {
                    // 1) vertical walls (underneath)
                    HStack(spacing: 0) {
                        if !cell.linked.contains("Left") {
                            Color.black.frame(width: wallWidth, height: size)
                        }
                        Spacer()
                        if !cell.linked.contains("Right") {
                            Color.black.frame(width: wallWidth, height: size)
                        }
                    }
                    
                    // 2) horizontal walls (on top!)
                    VStack(spacing: 0) {
                        if !cell.linked.contains("Up") {
                            Color.black.frame(width: size, height: wallWidth)
                        }
                        Spacer()
                        if !cell.linked.contains("Down") {
                            Color.black.frame(width: size, height: wallWidth)
                        }
                    }
                }
            )
            .frame(width: size, height: size)
    }
    
}


//struct OrthogonalCellView: View {
//    let cell: MazeCell
//    let size: CGFloat
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let selectedPalette: HeatMapPalette
//    let maxDistance: Int
//    let isRevealedSolution: Bool
//    let defaultBackgroundColor: Color
//
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(cellBackgroundColor(
//                                    for: cell,
//                                    showSolution: showSolution,
//                                    showHeatMap: showHeatMap,
//                                    maxDistance: maxDistance,
//                                    selectedPalette: selectedPalette,
//                                    isRevealedSolution: isRevealedSolution,
//                                    defaultBackground: defaultBackgroundColor
//                                ))
//                .frame(width: size, height: size)
//
//            Path { path in
//                let topLeft = CGPoint(x: 0, y: 0)
//                let topRight = CGPoint(x: size, y: 0)
//                let bottomLeft = CGPoint(x: 0, y: size)
//                let bottomRight = CGPoint(x: size, y: size)
//
//                if !cell.linked.contains("Up") {
//                    path.move(to: topLeft)
//                    path.addLine(to: topRight)
//                }
//                if !cell.linked.contains("Right") {
//                    path.move(to: topRight)
//                    path.addLine(to: bottomRight)
//                }
//                if !cell.linked.contains("Down") {
//                    path.move(to: bottomRight)
//                    path.addLine(to: bottomLeft)
//                }
//                if !cell.linked.contains("Left") {
//                    path.move(to: bottomLeft)
//                    path.addLine(to: topLeft)
//                }
//            }
//            .stroke(Color.black, lineWidth: cellStrokeWidth(for: size, mazeType: .orthogonal))
//            .frame(width: size, height: size)
//            .clipped()
//
//        }
//    }
//
//}
