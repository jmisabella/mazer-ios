//
//  OrthogonalMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

//struct OrthogonalMazeView: View {
//  @Binding var selectedPalette: HeatMapPalette
//  let cells: [MazeCell]
//  let showSolution: Bool
//  let showHeatMap: Bool
//
//  var body: some View {
//    MazeGridView(
//      selectedPalette: $selectedPalette,
//      cells: cells,
//      showSolution: showSolution,
//      showHeatMap: showHeatMap
//    ) { cell, size, isRevealed, shade in
//      OrthogonalCellView(
//        cell: cell,
//        size: size,
//        showSolution: showSolution,
//        showHeatMap: showHeatMap,
//        selectedPalette: selectedPalette,
//        maxDistance: cells.map(\.distance).max() ?? 1,
//        isRevealedSolution: isRevealed
//      )
//    }
//  }
//}



struct OrthogonalMazeView: View {
    @Binding var selectedPalette: HeatMapPalette
    @State private var revealedSolutionPath: Set<Coordinates> = []
    // Keep track of pending work items so they can be canceled
    @State private var pendingWorkItems: [DispatchWorkItem] = []
    let cells: [MazeCell]
    let showSolution: Bool
    let showHeatMap: Bool

    var body: some View {
        let width = (cells.map { $0.x }.max() ?? 0) + 1
        let height = (cells.map { $0.y }.max() ?? 0) + 1
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: width)
        let cellSize = cellSize()
        let maxDistance = cells.map(\.distance).max() ?? 1

        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(cells, id: \.self) { cell in
                OrthogonalCellView(
                    cell: cell,
                    size: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette,
                    maxDistance: maxDistance,
                    isRevealedSolution: revealedSolutionPath.contains(Coordinates(x: cell.x, y: cell.y))
                )
                .frame(width: cellSize, height: cellSize) // lock frame
                .clipped() // avoid any rendering overflow
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
    
    func cellSize() -> CGFloat {
        let width = (cells.map { $0.x }.max() ?? 0) + 1
        return UIScreen.main.bounds.width / CGFloat(width)
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
        let baseDelay: Double = 0.015
//        let delayMultiplier = min(1.0, cellSize() / 30.0)  // adjust 30.0 as needed
        let delayMultiplier = min(1.0, cellSize() / 50.0)  // adjust denominator as needed
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
//            return .green
            return .pink
        } else {
            return .gray
        }
    }


}
