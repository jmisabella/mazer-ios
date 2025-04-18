//
//  DeltaMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

//struct DeltaMazeView: View {
//  
//  let cells: [MazeCell]
//  let cellSize: CGFloat  // This represents the side length (base)
//  let showSolution: Bool
//  let showHeatMap: Bool
//  @Binding var selectedPalette: HeatMapPalette
//  let maxDistance: Int
//
//  var body: some View {
//    MazeGridView(
//      selectedPalette: $selectedPalette,
//      cells: cells,
//      showSolution: showSolution,
//      showHeatMap: showHeatMap
//    ) { cell, size, isRevealed, shade in
//        
//        DeltaCellView(
//            cell: cell,
//            cellSize: cellSize,
//            showSolution: showSolution,
//            showHeatMap: showHeatMap,
//            selectedPalette: selectedPalette,
//            maxDistance: maxDistance,
//            // your logic with Coordinates; for now, we pass false
//            isRevealedSolution: false
//        )
//    }
//  }
//}



struct DeltaMazeView: View {
    let cells: [MazeCell]
    let cellSize: CGFloat  // This represents the side length (base)
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    @State private var pendingWorkItems: [DispatchWorkItem] = []
    @State private var revealedSolutionPath: Set<Coordinates> = []
    
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
                                isRevealedSolution: revealedSolutionPath.contains(Coordinates(x: cell.x, y: cell.y))
                            )
                        } else {
                            // If no cell is found at this location, you can show an empty view.
                            EmptyView()
                        }
                    }
                }
            }
        }
        .onChange(of: showSolution) { oldValue, newValue in
            if newValue {
                animateSolutionPathReveal()
            } else {
                // Cancel pending work items before clearing the revealed path.
                for workItem in pendingWorkItems {
                    workItem.cancel()
                }
                pendingWorkItems.removeAll()
                revealedSolutionPath = []
            }
        }
        // Reset internal state when new maze cells are provided.
        .onChange(of: cells) { _ /*oldCells*/, newCells in
            for workItem in pendingWorkItems {
                workItem.cancel()
            }
            pendingWorkItems.removeAll()
            revealedSolutionPath = []
        }
        // Trigger solution animation on view appearance if showSolution is true.
        .onAppear {
            if showSolution {
                animateSolutionPathReveal()
            }
        }
    }
    
    
    
    func animateSolutionPathReveal() {
        // Clear any existing work items.
        pendingWorkItems.removeAll()
        
        // Get solution cells in order of distance from start
        let pathCells = cells
            .filter { $0.onSolutionPath }
            .sorted(by: { $0.distance < $1.distance })
        
        // Use cell size to determine an appropriate delay multiplier.
        // For example, if cellSize is smaller than some threshold, reduce the delay.
        let baseDelay: Double = 0.6
//        let delayMultiplier = min(1.0, cellSize() / 30.0)  // adjust 30.0 as needed
//        let delayMultiplier = min(1.0, cellSize() / 50.0)  // adjust denominator as needed
        let delayMultiplier = min(1.0, cellSize / 50.0)  // adjust denominator as needed
        let adjustedDelay = baseDelay * delayMultiplier
        
        for (index, cell) in pathCells.enumerated() {
            let workItem = DispatchWorkItem {
                withAnimation(.easeInOut(duration: 0.2 * delayMultiplier)) {
                    _ = revealedSolutionPath.insert(Coordinates(x: cell.x, y: cell.y))
                }
            }
            pendingWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * adjustedDelay, execute: workItem)
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
