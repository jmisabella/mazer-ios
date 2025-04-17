//
//  MazeGridView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/17/25.
//

import SwiftUI

struct MazeGridView<Content: View>: View {
    @Binding var selectedPalette: HeatMapPalette
    let cells: [MazeCell]
    let showSolution: Bool
    let showHeatMap: Bool

    /// Your cell‐drawing closure:
    /// - cell: the MazeCell
    /// - size: the computed cellSize
    /// - isRevealed: whether this cell is currently revealed in the solution animation
    /// - shade: the heat‐map color
    let content: (MazeCell, CGFloat, Bool, Color) -> Content

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []

    var body: some View {
        // 1) compute grid metrics
        let width     = (cells.map { $0.x }.max() ?? 0) + 1
        let columns   = Array(repeating: GridItem(.flexible(), spacing: 0), count: width)
        let cellSize  = UIScreen.main.bounds.width / CGFloat(width)
        let maxDist   = cells.map(\.distance).max() ?? 1

        LazyVGrid(columns: columns, spacing: 0) {
            // 2) iterate your MazeCell array directly
            ForEach(cells, id: \.self) { cell in
                // have to wrap coords in your Coordinates type
                let coord = Coordinates(x: cell.x, y: cell.y)
                let isRevealed = revealedSolutionPath.contains(coord)

                // compute heat‐map shade or fallback
                let shade = showHeatMap
                    ? selectedPalette.shades[min(9, (cell.distance * 10) / maxDist)].asColor
                    : .gray

                // delegate to your per‐cell view
                content(cell, cellSize, isRevealed, shade)
                    .frame(width: cellSize, height: cellSize)
                    .clipped()
            }
        }
        // solution animation hooks—identical to your Orthogonal version
        .onChange(of: showSolution) { _, new in
            if new { animateSolution() } else { resetSolution() }
        }
        .onChange(of: cells) { _, _ in
            resetSolution()
        }
        .onAppear {
            if showSolution { animateSolution() }
        }
    }

    // MARK: Helpers

    private func resetSolution() {
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        revealedSolutionPath.removeAll()
    }

    private func animateSolution() {
        resetSolution()
        let path = cells
            .filter(\.onSolutionPath)
            .sorted { $0.distance < $1.distance }

        let baseDelay = 0.015 * min(1,
            (UIScreen.main.bounds.width / CGFloat((cells.map { $0.x }.max() ?? 0) + 1))
            / 50
        )

        for (i, cell) in path.enumerated() {
            let coord = Coordinates(x: cell.x, y: cell.y)
            // Use the qos+flags initializer, and in the block ignore the tuple
            let item = DispatchWorkItem(qos: .unspecified, flags: []) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    _ = revealedSolutionPath.insert(coord)
                }
            }
            pendingWorkItems.append(item)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * baseDelay, execute: item)
        }
    }

}
