//
//  OrthogonalMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

struct OrthogonalMazeView: View {
    let cells: [MazeCell]
    let showSolution: Bool
    let showHeatMap: Bool

    var body: some View {
        let width = (cells.map { $0.x }.max() ?? 0) + 1
        let height = (cells.map { $0.y }.max() ?? 0) + 1
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: width)
        let cellSize = UIScreen.main.bounds.width / CGFloat(width)

        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(cells, id: \.self) { cell in
                OrthogonalCellView(
                    cell: cell,
                    size: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap
                )
            }
        }
    }
}
