//
//  HexMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/22/25.
//

import SwiftUI

struct SigmaMazeView: View {
    @Binding var selectedPalette: HeatMapPalette
    let cells: [MazeCell]
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []

    private var maxDistance: Int { cells.map(\.distance).max() ?? 1 }

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .topLeading) {
                ForEach(cells, id: \.self) { cell in
                    SigmaCellView(
                        cell: cell,
                        cellSize: cellSize,
                        showSolution: showSolution,
                        showHeatMap: showHeatMap,
                        selectedPalette: selectedPalette,
                        maxDistance: maxDistance,
                        isRevealedSolution: revealedSolutionPath.contains(
                            Coordinates(x: cell.x, y: cell.y)
                        )
                    )
                    .offset(
                        x: xOffset(for: cell),
                        y: yOffset(for: cell)
                    )
                }
            }
            .onChange(of: showSolution) { _, new in
                if new { animateSolutionPathReveal() }
                else { cancelAndReset() }
            }
            .onChange(of: cells) { _ in
                cancelAndReset()
            }
            .onAppear {
                if showSolution { animateSolutionPathReveal() }
            }
        }
    }

    // axial→pixel for a flat-topped hex grid
    private func xOffset(for cell: MazeCell) -> CGFloat {
        cellSize * 1.5 * CGFloat(cell.x)
    }
    private func yOffset(for cell: MazeCell) -> CGFloat {
        cellSize * sqrt(3) * (CGFloat(cell.y) + CGFloat(cell.x) * 0.5)
    }

    // cancel any pending animations and clear
    private func cancelAndReset() {
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        revealedSolutionPath.removeAll()
    }

    // match your other views’ “draw-solution” animation pattern
    private func animateSolutionPathReveal() {
        let pathCells = cells
            .filter { $0.onSolutionPath }
            .sorted(by: { $0.distance < $1.distance })

        var delay = 0.0
        for c in pathCells {
            let coord = Coordinates(x: c.x, y: c.y)

            // force the 3-arg init by spelling out qos & flags
            let work = DispatchWorkItem(
                qos: .default,
                flags: [],
                block: {
                    withAnimation(.linear(duration: 0.1)) {
                        _ = revealedSolutionPath.insert(coord)
                    }
                }
            )

            pendingWorkItems.append(work)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
            delay += 0.05
        }
    }

    
    private func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
        guard showHeatMap, maxDistance > 0 else {
            return .gray  // fallback color when heat map is off
        }

        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    }
    
    private func defaultCellColor(for cell: MazeCell) -> Color {
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
