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
    
//    private var strokeWidth: CGFloat {
//        let raw = cellSize / 5.5
//        let scale = UIScreen.main.scale
//        return (raw * scale).rounded() / scale
//    }
    private var strokeWidth: CGFloat {
        wallStrokeWidth(for: .orthogonal, cellSize: cellSize)
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
                    // Vertical walls (underneath)
                    HStack(spacing: 0) {
                        if !cell.linked.contains("Left") {
                            Color.black
                                .frame(width: strokeWidth, height: size)
                                .offset(x: -strokeWidth / 2) // Shift slightly left to ensure no gap
                        }
                        Spacer()
                        if !cell.linked.contains("Right") {
                            Color.black
                                .frame(width: strokeWidth, height: size)
                                .offset(x: strokeWidth / 2) // Shift slightly right to ensure no gap
                        }
                    }
                    
                    // Horizontal walls (on top)
                    VStack(spacing: 0) {
                        if !cell.linked.contains("Up") {
                            Color.black
                                .frame(width: size, height: strokeWidth)
                                .offset(y: -strokeWidth / 2) // Shift slightly up to ensure no gap
                        }
                        Spacer()
                        if !cell.linked.contains("Down") {
                            Color.black
                                .frame(width: size, height: strokeWidth)
                                .offset(y: strokeWidth / 2) // Shift slightly down to ensure no gap
                        }
                    }
                }
            )
            .frame(width: size, height: size)
    }
    
}

