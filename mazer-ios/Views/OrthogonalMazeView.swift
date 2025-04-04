//
//  OrthogonalMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

struct OrthogonalMazeView: View {
    @Binding var selectedPalette: HeatMapPalette
    let cells: [MazeCell]
    let showSolution: Bool
    let showHeatMap: Bool

    var body: some View {
        let width = (cells.map { $0.x }.max() ?? 0) + 1
        let height = (cells.map { $0.y }.max() ?? 0) + 1
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: width)
        let cellSize = UIScreen.main.bounds.width / CGFloat(width)
        let maxDistance = cells.map(\.distance).max() ?? 1

        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(cells, id: \.self) { cell in
                OrthogonalCellView(
                    cell: cell,
                    size: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette,
                    maxDistance: maxDistance
                )
                .frame(width: cellSize, height: cellSize) // lock frame
                .clipped() // avoid any rendering overflow
            }
        }
    }
    
    func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
        guard showHeatMap, maxDistance > 0 else {
            return .gray  // fallback color when heat map is off
        }

        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    }
    
    func defaultCellColor(for cell: MazeCell) -> Color {
        if cell.isStart {
            return .blue
        } else if cell.isGoal {
            return .red
        } else if cell.onSolutionPath {
            return .green
        } else {
            return .gray
        }
    }


}
