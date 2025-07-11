import SwiftUI
import AudioToolbox
import UIKit  // for UIFeedbackGenerator

struct CellMapEnvironmentKey: EnvironmentKey {
    static let defaultValue: [Coordinates: MazeCell] = [:]
}

extension EnvironmentValues {
    var cellMap: [Coordinates: MazeCell] {
        get { self[CellMapEnvironmentKey.self] }
        set { self[CellMapEnvironmentKey.self] = newValue }
    }
}

struct SigmaMazeView: View {
    @Binding var selectedPalette: HeatMapPalette
    let cells: [MazeCell]
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let defaultBackgroundColor: Color

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []

    private let cols: Int
    private let rows: Int
    private let hexHeight: CGFloat
    private let totalWidth: CGFloat
    private let totalHeight: CGFloat
    private let maxDistance: Int
    private let cellMap: [Coordinates: MazeCell]
    private let totalRows: Int

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

        self.cols = (cells.map(\.x).max() ?? 0) + 1
        self.rows = (cells.map(\.y).max() ?? 0) + 1
        self.hexHeight = sqrt(3) * cellSize
        self.totalWidth = cellSize * (1.5 * CGFloat(cols) + 0.5)
        self.totalHeight = hexHeight * (CGFloat(rows) + 0.5)
        self.maxDistance = cells.map(\.distance).max() ?? 1
        self.totalRows = rows

        var m = [Coordinates: MazeCell]()
        for c in cells { m[Coordinates(x: c.x, y: c.y)] = c }
        self.cellMap = m
    }

    private func position(for cell: MazeCell) -> CGPoint {
        let q = CGFloat(cell.x)
        let r = CGFloat(cell.y)
        let x = cellSize * 1.5 * q + cellSize
        let yOffset = (q.truncatingRemainder(dividingBy: 2) == 0) ? 0 : hexHeight / 2
        let y = hexHeight * r + hexHeight / 2 + yOffset
        return .init(x: x, y: y)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(cells.indices, id: \.self) { i in
                let cell = cells[i]
                SigmaCellView(
                    cell: cell,
                    cellSize: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette,
                    maxDistance: maxDistance,
                    isRevealedSolution: revealedSolutionPath.contains(Coordinates(x: cell.x, y: cell.y)),
                    defaultBackgroundColor: defaultBackgroundColor,
                    totalRows: totalRows
                )
                .position(position(for: cell))
            }
        }
        .drawingGroup()
        .frame(width: totalWidth, height: totalHeight)
        .environment(\.cellMap, cellMap) // Inject cellMap into the environment
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

////
////  HexMazeView.swift
////  mazer-ios
////
////  Created by Jeffrey Isabella on 4/22/25.
////
//
//import SwiftUI
//import AudioToolbox
//import UIKit  // for UIFeedbackGenerator
//
//struct CellMapEnvironmentKey: EnvironmentKey {
//    static let defaultValue: [Coordinates: MazeCell] = [:]
//}
//
//extension EnvironmentValues {
//    var cellMap: [Coordinates: MazeCell] {
//        get { self[CellMapEnvironmentKey.self] }
//        set { self[CellMapEnvironmentKey.self] = newValue }
//    }
//}
//
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
//    private let cols: Int
//    private let rows: Int
//    private let hexHeight: CGFloat
//    private let totalWidth: CGFloat
//    private let totalHeight: CGFloat
//    private let maxDistance: Int
//    private let cellMap: [Coordinates: MazeCell]
//
//    init(
//        selectedPalette: Binding<HeatMapPalette>,
//        cells: [MazeCell],
//        cellSize: CGFloat,
//        showSolution: Bool,
//        showHeatMap: Bool,
//        defaultBackgroundColor: Color
//    ) {
//        self._selectedPalette = selectedPalette
//        self.cells = cells
//        self.cellSize = cellSize
//        self.showSolution = showSolution
//        self.showHeatMap = showHeatMap
//        self.defaultBackgroundColor = defaultBackgroundColor
//
//        self.cols = (cells.map(\.x).max() ?? 0) + 1
//        self.rows = (cells.map(\.y).max() ?? 0) + 1
//        self.hexHeight = sqrt(3) * cellSize
//        self.totalWidth = cellSize * (1.5 * CGFloat(cols) + 0.5)
//        self.totalHeight = hexHeight * (CGFloat(rows) + 0.5)
//        self.maxDistance = cells.map(\.distance).max() ?? 1
//
//        var m = [Coordinates: MazeCell]()
//        for c in cells { m[Coordinates(x: c.x, y: c.y)] = c }
//        self.cellMap = m
//    }
//
//    private func position(for cell: MazeCell) -> CGPoint {
//        let q = CGFloat(cell.x)
//        let r = CGFloat(cell.y)
//        let x = cellSize * 1.5 * q + cellSize
//        let yOffset = (q.truncatingRemainder(dividingBy: 2) == 0) ? 0 : hexHeight / 2
//        let y = hexHeight * r + hexHeight / 2 + yOffset
//        return .init(x: x, y: y)
//    }
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            ForEach(cells.indices, id: \.self) { i in
//                let cell = cells[i]
//                SigmaCellView(
//                    cell: cell,
//                    cellSize: cellSize,
//                    showSolution: showSolution,
//                    showHeatMap: showHeatMap,
//                    selectedPalette: selectedPalette,
//                    maxDistance: maxDistance,
//                    isRevealedSolution: revealedSolutionPath.contains(Coordinates(x: cell.x, y: cell.y)),
//                    defaultBackgroundColor: defaultBackgroundColor
//                )
//                .position(position(for: cell))
//            }
//        }
//        .drawingGroup()
//        .frame(width: totalWidth, height: totalHeight)
//        .environment(\.cellMap, cellMap) // Inject cellMap into the environment
//        .onChange(of: showSolution) { _, new in
//            new ? animateSolutionPathReveal() : cancelAndReset()
//        }
//        .onChange(of: cells) { _ in cancelAndReset() }
//        .onAppear { if showSolution { animateSolutionPathReveal() } }
//    }
//
//    private func cancelAndReset() {
//        pendingWorkItems.forEach { $0.cancel() }
//        pendingWorkItems.removeAll()
//        revealedSolutionPath.removeAll()
//    }
//
//    private func animateSolutionPathReveal() {
//        cancelAndReset()
//        let pathCells = cells
//            .filter { $0.onSolutionPath && !$0.isVisited }
//            .sorted { $0.distance < $1.distance }
//
//        let rapidDelay: Double = 0.05
//        let haptic = UIImpactFeedbackGenerator(style: .light)
//        haptic.prepare()
//
//        for (i, c) in pathCells.enumerated() {
//            let coord = Coordinates(x: c.x, y: c.y)
//            let work = DispatchWorkItem {
//                AudioServicesPlaySystemSound(1104)
//                haptic.impactOccurred()
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
//}
