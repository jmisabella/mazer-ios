//
//  DeltaMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

struct DeltaMazeView: View {
    let cells: [MazeCell]
    let cellSize: CGFloat  // This represents the side length (base)
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    
    
    // You can either pass these in or compute from cells.
    // For instance, if x and y are zero-indexed in MazeCell:
    var columns: Int {
        (cells.map { $0.x }.max() ?? 0) + 1
    }
    var rows: Int {
        (cells.map { $0.y }.max() ?? 0) + 1
    }

    /// Compute the height for an equilateral triangle.
    var triangleHeight: CGFloat {
//        cellSize * 2 * CGFloat(sqrt(3)) / 2.0
        cellSize * sqrt(3) / 2
    }

    var body: some View {
        // Use a spacing of -triangleHeight/2 to ensure proper overlap.
//        VStack(spacing: -triangleHeight / 2) {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { rowIndex in
                HStack(spacing: -cellSize / 2) {
                    ForEach(0..<columns, id: \.self) { colIndex in
                        // Look up the MazeCell that has matching x and y
                        if let cell = cells.first(where: { $0.x == colIndex && $0.y == rowIndex }) {
                            DeltaCellView(
                                cell: cell,
                                cellSize: cellSize,
                                showSolution: showSolution,
                                showHeatMap: showHeatMap,
                                selectedPalette: selectedPalette,
                                maxDistance: maxDistance,
                                // your logic with Coordinates; for now, we pass false
                                isRevealedSolution: false
                            )
                        } else {
                            // If no cell is found at this location, you can show an empty view.
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}


//
//struct DeltaMazeView: View {
//    let cells: [MazeCell]
//    let cellSize: CGFloat  // This represents the side length (base)
//    // Additional properties as needed
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let selectedPalette: HeatMapPalette
//    let maxDistance: Int
//
//    /// Compute the height for an equilateral triangle.
//    var triangleHeight: CGFloat {
//        cellSize * CGFloat(sqrt(3)) / 2.0
//    }
//
//    var body: some View {
//        let width = (cells.map { $0.x }.max() ?? 0) + 1
//        let height = (cells.map { $0.y }.max() ?? 0) + 1
//        
//        // Group cells by their y coordinate.
//        let rows = Dictionary(grouping: cells, by: \.y)
//        let sortedRowIndices = rows.keys.sorted()
//        
//        VStack(spacing: -triangleHeight * 0.3) { // Negative spacing to force overlap—adjust as needed.
//            ForEach(sortedRowIndices, id: \.self) { rowIndex in
//                HStack(spacing: 0) {
//                    let rowCells = rows[rowIndex]?.sorted(by: { $0.x < $1.x }) ?? []
//                    ForEach(rowCells, id: \.self) { cell in
//                        DeltaCellView(
//                            cell: cell,
//                            cellSize: cellSize,
//                            showSolution: showSolution,
//                            showHeatMap: showHeatMap,
//                            selectedPalette: selectedPalette,
//                            maxDistance: maxDistance,
//                            isRevealedSolution: /* your logic using Coordinates here */
//                                false
//                        )
//                    }
//                }
//                // Offset every other row horizontally by half of cellSize.
//                .offset(x: rowIndex.isMultiple(of: 2) ? 0 : cellSize / 2)
//            }
//        }
//    }
//}
