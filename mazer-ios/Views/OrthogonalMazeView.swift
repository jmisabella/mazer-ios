//
//  OrthogonalMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI
import AudioToolbox
import UIKit  // for UIFeedbackGenerator

struct OrthogonalMazeView: View {
    @Binding var selectedPalette: HeatMapPalette
    let cells: [MazeCell]
    let showSolution: Bool
    let showHeatMap: Bool
    let defaultBackgroundColor: Color

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []
    @State private var sortedSolutionCoordinates: [Coordinates] = []

    // Precomputed once in init
    private let columns: [GridItem]
    private let cellSize: CGFloat
    private let maxDistance: Int
    private let strokeWidth: CGFloat

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    init(
        selectedPalette: Binding<HeatMapPalette>,
        cells: [MazeCell],
        showSolution: Bool,
        showHeatMap: Bool,
        defaultBackgroundColor: Color
    ) {
        self._selectedPalette = selectedPalette
        self.cells = cells
        self.showSolution = showSolution
        self.showHeatMap = showHeatMap
        self.defaultBackgroundColor = defaultBackgroundColor

        // 1) build columns
        let cols = (cells.map(\.x).max() ?? 0) + 1
        self.columns = Array(
            repeating: GridItem(.flexible(), spacing: 0),
            count: cols
        )

        // 2) cell size once
        let screenW = UIScreen.main.bounds.width
        self.cellSize = screenW / CGFloat(cols)

        // 3) maxDistance once
        self.maxDistance = cells.map(\.distance).max() ?? 1

        // 4) stroke width once
        let raw = cellStrokeWidth(for: cellSize, mazeType: .orthogonal)
        let scale = UIScreen.main.scale
        self.strokeWidth = (raw * scale).rounded() / scale

        // 5) precompute solution path coords
        self.sortedSolutionCoordinates = cells
            .filter { $0.onSolutionPath && !$0.isVisited }
            .sorted { $0.distance < $1.distance }
            .map { Coordinates(x: $0.x, y: $0.y) }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(cells.indices, id: \.self) { i in
                let cell = cells[i]
                let coord = Coordinates(x: cell.x, y: cell.y)
                OrthogonalCellView(
                    cell: cell,
                    size: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette,
                    maxDistance: maxDistance,
                    isRevealedSolution: revealedSolutionPath.contains(coord),
                    defaultBackgroundColor: defaultBackgroundColor,
                    strokeWidth: strokeWidth
                )
            }
        }
        .drawingGroup()  // batch once
        .onChange(of: showSolution) { _, new in
            new ? animateSolutionPathReveal() : cancelAndReset()
        }
        .onChange(of: cells) { _, newCells in
            cancelAndReset()
            sortedSolutionCoordinates = newCells
                .filter { $0.onSolutionPath && !$0.isVisited }
                .sorted { $0.distance < $1.distance }
                .map { Coordinates(x: $0.x, y: $0.y) }
        }
        .onAppear {
            if showSolution { animateSolutionPathReveal() }
        }
    }

    private func cancelAndReset() {
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        revealedSolutionPath.removeAll()
    }

    private func animateSolutionPathReveal() {
        cancelAndReset()
        haptic.prepare()

        let baseDelay: Double = 0.015
        let mult = min(1.0, cellSize / 50.0)
        let interval = baseDelay * mult

        for (i, coord) in sortedSolutionCoordinates.enumerated() {
            let work = DispatchWorkItem {
                AudioServicesPlaySystemSound(1104)
                haptic.impactOccurred()
                withAnimation(.none) {
                    _ = revealedSolutionPath.insert(coord)
                }
            }
            pendingWorkItems.append(work)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(i) * interval,
                execute: work
            )
        }
    }
}

//
//struct OrthogonalMazeView: View {
//    @Binding var selectedPalette: HeatMapPalette
//    @State private var revealedSolutionPath: Set<Coordinates> = []
//    // Keep track of pending work items so they can be canceled
//    @State private var pendingWorkItems: [DispatchWorkItem] = []
//    let cells: [MazeCell]
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let defaultBackgroundColor: Color
//    
//    private let haptic = UIImpactFeedbackGenerator(style: .light)
//
//    var body: some View {
//        let width = (cells.map { $0.x }.max() ?? 0) + 1
//        let height = (cells.map { $0.y }.max() ?? 0) + 1
//        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: width)
//        let cellSize = cellSize()
//        let maxDistance = cells.map(\.distance).max() ?? 1
//
//        LazyVGrid(columns: columns, spacing: 0) {
//            ForEach(cells, id: \.self) { cell in
//                OrthogonalCellView(
//                    cell: cell,
//                    size: cellSize,
//                    showSolution: showSolution,
//                    showHeatMap: showHeatMap,
//                    selectedPalette: selectedPalette,
//                    maxDistance: maxDistance,
//                    isRevealedSolution: revealedSolutionPath.contains(Coordinates(x: cell.x, y: cell.y)),
//                    defaultBackgroundColor: defaultBackgroundColor
//                )
//                .frame(width: cellSize, height: cellSize) // lock frame
//                .clipped() // avoid any rendering overflow
//            }
//        }
//        .onChange(of: showSolution) { oldValue, newValue in
//            if newValue {
//                animateSolutionPathReveal()
//            } else {
//                // Cancel pending work items before clearing the revealed path.
//                for workItem in pendingWorkItems {
//                    workItem.cancel()
//                }
//                pendingWorkItems.removeAll()
//                revealedSolutionPath = []
//            }
//        }
//        // Reset internal state when new maze cells are provided.
//        .onChange(of: cells) { _ /*oldCells*/, newCells in
//            for workItem in pendingWorkItems {
//                workItem.cancel()
//            }
//            pendingWorkItems.removeAll()
//            revealedSolutionPath = []
//        }
//        // Trigger solution animation on view appearance if showSolution is true.
//        .onAppear {
//            if showSolution {
//                animateSolutionPathReveal()
//            }
//        }
//    }
//    
//    func cellSize() -> CGFloat {
//        let width = (cells.map { $0.x }.max() ?? 0) + 1
//        return UIScreen.main.bounds.width / CGFloat(width)
//    }
//    
//    func animateSolutionPathReveal() {
//        // 1. Cancel any pending reveals
//        pendingWorkItems.forEach { $0.cancel() }
//        pendingWorkItems.removeAll()
//        
//        // 2. Build your ordered solution path from unvisited cells
//        let pathCells = cells
//            .filter { cell in
//                cell.onSolutionPath && !cell.isVisited
//            }
//            .sorted(by: { $0.distance < $1.distance })
//        
//        // 3. Compute a fixed interval between reveals
//        let baseDelay: Double = 0.015
//        let delayMultiplier = min(1.0, cellSize() / 50.0)
//        let interval = baseDelay * delayMultiplier
//        
//        // Prepare the haptic engine _before_ we even do the move
//        haptic.prepare()
//        
//        // 4. Schedule each reveal WITHOUT animation and with a click
//        for (index, cell) in pathCells.enumerated() {
//            let work = DispatchWorkItem {
//                AudioServicesPlaySystemSound(1104) // play a `click` sound on audio
//                haptic.impactOccurred() // cause user to feel a `bump`
//                // Disable implicit animation
//                withAnimation(.none) {
//                    _ = revealedSolutionPath.insert(
//                        Coordinates(x: cell.x, y: cell.y)
//                    )
//                }
//            }
//            pendingWorkItems.append(work)
//            DispatchQueue.main.asyncAfter(
//                deadline: .now() + Double(index) * interval,
//                execute: work
//            )
//        }
//    }
//     
//    func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
//        guard showHeatMap, maxDistance > 0 else {
//            return .gray  // fallback color when heat map is off
//        }
//
//        let index = min(9, (cell.distance * 10) / maxDistance)
//        return selectedPalette.shades[index].asColor
//    }
//    
//    func defaultCellColor(for cell: MazeCell) -> Color {
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
//
//
//}
