import SwiftUI

struct OrthogonalCellView: View {
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color
    let optionalColor: Color?
    let totalRows: Int

    /// Snap any value to the pixel grid
    private func snap(_ x: CGFloat) -> CGFloat {
        let s = UIScreen.main.scale
        return (x * s).rounded() / s
    }
    
    private var size: CGFloat { snap(cellSize) }
    
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
                    defaultBackground: defaultBackgroundColor,
                    totalRows: totalRows,
                    optionalColor: optionalColor
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
