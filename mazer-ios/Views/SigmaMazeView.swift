//
//  HexMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/22/25.
//

import SwiftUI
import AudioToolbox
import UIKit  // for UIFeedbackGenerator

struct SigmaMazeView: View {
    @Binding var selectedPalette: HeatMapPalette
    let cells: [MazeCell]
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let defaultBackgroundColor: Color

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []

    // Precomputed once in init
    private let cols: Int
    private let rows: Int
    private let hexHeight: CGFloat
    private let totalWidth: CGFloat
    private let totalHeight: CGFloat
    private let maxDistance: Int
    private let cellMap: [Coordinates: MazeCell]

    init(
        selectedPalette: Binding<HeatMapPalette>,
        cells: [MazeCell],
        cellSize: CGFloat,
        showSolution: Bool,
        showHeatMap: Bool,
        defaultBackgroundColor: Color
    ) {
        self._selectedPalette = selectedPalette
        self.cells = cells
        self.cellSize = cellSize
        self.showSolution = showSolution
        self.showHeatMap = showHeatMap
        self.defaultBackgroundColor = defaultBackgroundColor

        // aggregate properties
        self.cols = (cells.map(\.x).max() ?? 0) + 1
        self.rows = (cells.map(\.y).max() ?? 0) + 1
        self.hexHeight = sqrt(3) * cellSize
        self.totalWidth = cellSize * (1.5 * CGFloat(cols) + 0.5)
        self.totalHeight = hexHeight * (CGFloat(rows) + 0.5)
        self.maxDistance = cells.map(\.distance).max() ?? 1

        // build lookup once
        var m = [Coordinates: MazeCell]()
        for c in cells { m[Coordinates(x: c.x, y: c.y)] = c }
        self.cellMap = m
    }

    private func position(for cell: MazeCell) -> CGPoint {
        let q = CGFloat(cell.x)
        let r = CGFloat(cell.y)
        let x = cellSize * 1.5 * q + cellSize
        let yOffset = (q.truncatingRemainder(dividingBy: 2) == 0)
            ? 0
            : hexHeight / 2
        let y = hexHeight * r + hexHeight / 2 + yOffset
        return .init(x: x, y: y)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(cells.indices, id: \.self) { i in
                let cell = cells[i]
                SigmaCellView(
                    cell: cell,
                    cellMap: cellMap,
                    cellSize: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette,
                    maxDistance: maxDistance,
                    isRevealedSolution: revealedSolutionPath.contains(
                        Coordinates(x: cell.x, y: cell.y)
                    ),
                    defaultBackgroundColor: defaultBackgroundColor
                )
                .position(position(for: cell))
            }
        }
        .drawingGroup()  // only once at the grid level
        .frame(width: totalWidth, height: totalHeight)
        .onChange(of: showSolution) { _, new in
            new ? animateSolutionPathReveal() : cancelAndReset()
        }
        .onChange(of: cells) { _ in cancelAndReset() }
        .onAppear { if showSolution { animateSolutionPathReveal() } }
    }

    private func cancelAndReset() {
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        revealedSolutionPath.removeAll()
    }

    private func animateSolutionPathReveal() {
        cancelAndReset()
        let pathCells = cells
            .filter { $0.onSolutionPath && !$0.isVisited }
            .sorted { $0.distance < $1.distance }

        let rapidDelay: Double = 0.05
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()

        for (i, c) in pathCells.enumerated() {
            let coord = Coordinates(x: c.x, y: c.y)
            let work = DispatchWorkItem {
                AudioServicesPlaySystemSound(1104)
                haptic.impactOccurred()
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
}
//struct SigmaMazeView: View {
//    @Binding var selectedPalette: HeatMapPalette
//    let cells: [MazeCell]
//    let cellSize: CGFloat
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let defaultBackgroundColor: Color
//
//    @State private var revealedSolutionPath: Set<Coordinates> = []
//    @State private var pendingWorkItems: [DispatchWorkItem] = []
//    
//    // computed properties
//    private var cols: Int {
//        (cells.map(\.x).max() ?? 0) + 1
//    }
//    private var rows: Int {
//        (cells.map(\.y).max() ?? 0) + 1
//    }
//    private var hexHeight: CGFloat {
//        sqrt(3) * cellSize
//    }
//    private var totalWidth: CGFloat {
//        cellSize * (1.5 * CGFloat(cols) + 0.5)
//    }
//    private var totalHeight: CGFloat {
//        hexHeight * (CGFloat(rows) + 0.5)
//    }
//
//    private var maxDistance: Int { cells.map(\.distance).max() ?? 1 }
//
//    private func position(for cell: MazeCell) -> CGPoint {
//      let s = cellSize
//      let q = CGFloat(cell.x)
//      let r = CGFloat(cell.y)
//
//      let x = s * 1.5 * q + s
//      let hexH = sqrt(3) * s
//      let yOffset = (q.truncatingRemainder(dividingBy: 2) == 0) ? 0 : hexH/2
//      let y = hexH * r + hexH/2 + yOffset
//
//      return CGPoint(x: x, y: y)
//    }
//    
//    private let haptic = UIImpactFeedbackGenerator(style: .light)
//    
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            ForEach(cells, id: \.self) { cell in
//                SigmaCellView(
//                    allCells: cells, // TODO: REMOVE DEBUG LINE
//                    cell: cell,
//                    cellSize: cellSize,
//                    showSolution: showSolution,
//                    showHeatMap: showHeatMap,
//                    selectedPalette: selectedPalette,
//                    maxDistance: maxDistance,
//                    isRevealedSolution: revealedSolutionPath.contains(
//                        Coordinates(x: cell.x, y: cell.y)
//                    ),
//                    defaultBackgroundColor: defaultBackgroundColor
//                )
//                .position(position(for: cell))
//                //                    .offset(
//                //                        x: xOffset(for: cell),
//                //                        y: yOffset(for: cell)
//                //                    )
//            }
//        }
//        // Flatten the entire grid to avoid any sub-pixel seams between rows
//        .compositingGroup()
//        .drawingGroup(opaque: true)
//        .clipped(antialiased: false)
//        .frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
//        .onChange(of: showSolution) { _, new in
//            if new { animateSolutionPathReveal() }
//            else { cancelAndReset() }
//        }
//        .onChange(of: cells) { _ in
//            cancelAndReset()
//        }
//        .onAppear {
//            if showSolution { animateSolutionPathReveal() }
//        }
//        
//    }
//
//    // axial→pixel for a flat-topped hex grid
//    private func xOffset(for cell: MazeCell) -> CGFloat {
//        cellSize * 1.5 * CGFloat(cell.x)
//    }
//    private func yOffset(for cell: MazeCell) -> CGFloat {
//        cellSize * sqrt(3) * (CGFloat(cell.y) + CGFloat(cell.x) * 0.5)
//    }
//
//    // cancel any pending animations and clear
//    private func cancelAndReset() {
//        pendingWorkItems.forEach { $0.cancel() }
//        pendingWorkItems.removeAll()
//        revealedSolutionPath.removeAll()
//    }
//
//    // match your other views’ “draw-solution” animation pattern
//    private func animateSolutionPathReveal() {
//        // 1. Cancel any in-flight reveals
//        pendingWorkItems.forEach { $0.cancel() }
//        pendingWorkItems.removeAll()
//        revealedSolutionPath.removeAll()
//        
//        // 2. Grab your ordered solution from unvisited cells
//        let pathCells = cells
//            .filter { cell in
//                cell.onSolutionPath && !cell.isVisited
//            }
//            .sorted { $0.distance < $1.distance }
//        
//        // 3. How fast between pops
//        let rapidDelay: Double = 0.05
//        
//        // Prepare the haptic engine _before_ we even do the move
//        haptic.prepare()
//        
//        // 4. Schedule each pop + click
//        for (i, c) in pathCells.enumerated() {
//            let coord = Coordinates(x: c.x, y: c.y)
//            let work = DispatchWorkItem {
//                AudioServicesPlaySystemSound(1104) // play a `click` sound on audio
//                haptic.impactOccurred() // cause user to feel a `bump`
//                // NO animation → instant “pop”
//                withAnimation(.none) {
//                    _ = revealedSolutionPath.insert(coord)
//                }
//            }
//            pendingWorkItems.append(work)
//            DispatchQueue.main.asyncAfter(
//                deadline: .now() + Double(i) * rapidDelay,
//                execute: work
//            )
//        }
//    }
//    
//    private func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
//        guard showHeatMap, maxDistance > 0 else {
//            return .gray  // fallback color when heat map is off
//        }
//
//        let index = min(9, (cell.distance * 10) / maxDistance)
//        return selectedPalette.shades[index].asColor
//    }
//    
//    private func defaultCellColor(for cell: MazeCell) -> Color {
//        if cell.isStart {
//            return .blue
//        } else if cell.isGoal {
//            return .red
//        } else if cell.onSolutionPath {
////            return .green
//            return .pink
//        } else {
//            return .gray
//        }
//    }
//}
