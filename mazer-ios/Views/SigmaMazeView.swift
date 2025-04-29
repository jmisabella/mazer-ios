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
    
    // computed properties
    private var cols: Int {
        (cells.map(\.x).max() ?? 0) + 1
    }
    private var rows: Int {
        (cells.map(\.y).max() ?? 0) + 1
    }
    private var hexHeight: CGFloat {
        sqrt(3) * cellSize
    }
    private var totalWidth: CGFloat {
        cellSize * (1.5 * CGFloat(cols) + 0.5)
    }
    private var totalHeight: CGFloat {
        hexHeight * (CGFloat(rows) + 0.5)
    }

    private var maxDistance: Int { cells.map(\.distance).max() ?? 1 }

    private func position(for cell: MazeCell) -> CGPoint {
      let s = cellSize
      let q = CGFloat(cell.x)
      let r = CGFloat(cell.y)

      let x = s * 1.5 * q + s
      let hexH = sqrt(3) * s
      let yOffset = (q.truncatingRemainder(dividingBy: 2) == 0) ? 0 : hexH/2
      let y = hexH * r + hexH/2 + yOffset

      return CGPoint(x: x, y: y)
    }
    

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(cells, id: \.self) { cell in
                SigmaCellView(
                    allCells: cells, // TODO: REMOVE DEBUG LINE
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
                .position(position(for: cell))
                //                    .offset(
                //                        x: xOffset(for: cell),
                //                        y: yOffset(for: cell)
                //                    )
            }
        }
        // Flatten the entire grid to avoid any sub-pixel seams between rows
        .compositingGroup()
        .drawingGroup(opaque: true)
        .frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
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
        // 1. Cancel any in-flight reveals
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        revealedSolutionPath.removeAll()
        
        // 2. Grab your ordered solution cells
        let pathCells = cells
            .filter(\.onSolutionPath)
            .sorted { $0.distance < $1.distance }
        
        // 3. How fast between pops
        let rapidDelay: Double = 0.05
        
        // 4. Schedule each pop + click
        for (i, c) in pathCells.enumerated() {
            let coord = Coordinates(x: c.x, y: c.y)
            let work = DispatchWorkItem {
                // NO animation → instant “pop”
                withAnimation(.none) {
                    _ = revealedSolutionPath.insert(coord)
                }
            }
            pendingWorkItems.append(work)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(i) * rapidDelay,
                execute: work
            )
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
