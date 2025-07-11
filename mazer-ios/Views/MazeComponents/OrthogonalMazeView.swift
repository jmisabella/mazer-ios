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

    private let columns: [GridItem]
    private let cellSize: CGFloat
    private let maxDistance: Int
    private let totalRows: Int

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    @Environment(\.colorScheme) private var colorScheme // Access the color scheme

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

        let cols = (cells.map(\.x).max() ?? 0) + 1
        self.columns = Array(
            repeating: GridItem(.flexible(), spacing: 0),
            count: cols
        )

        let screenW = UIScreen.main.bounds.width
        let rawSize = screenW / CGFloat(cols)
        let scale = UIScreen.main.scale
        self.cellSize = (rawSize * scale).rounded() / scale

        self.maxDistance = cells.map(\.distance).max() ?? 1
        self.totalRows = (cells.map(\.y).max() ?? 0) + 1
    }

    // Computed property for total width
    private var totalWidth: CGFloat {
        let cols = (cells.map(\.x).max() ?? 0) + 1
        return cellSize * CGFloat(cols)
    }

    // Computed property for total height
    private var totalHeight: CGFloat {
        let rows = (cells.map(\.y).max() ?? 0) + 1
        return cellSize * CGFloat(rows)
    }

    // Background view
    private var background: some View {
        (colorScheme == .dark ? Color.black : CellColors.offWhite)
            .frame(width: totalWidth, height: totalHeight)
    }

    // Maze grid view
    private var mazeGrid: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(cells.indices, id: \.self) { i in
                cellView(for: i)
            }
        }
        .drawingGroup()  // Batch offscreen rendering
    }

    // Cell view builder
    @ViewBuilder
    private func cellView(for index: Int) -> some View {
        let cell = cells[index]
        let coord = Coordinates(x: cell.x, y: cell.y)
        OrthogonalCellView(
            cell: cell,
            cellSize: cellSize,
            showSolution: showSolution,
            showHeatMap: showHeatMap,
            selectedPalette: selectedPalette,
            maxDistance: maxDistance,
            isRevealedSolution: revealedSolutionPath.contains(coord),
            defaultBackgroundColor: defaultBackgroundColor,
            totalRows: totalRows
        )
        .frame(width: cellSize, height: cellSize)
    }

    // Border overlay view
    private var borderOverlay: some View {
        Rectangle()
            .stroke(Color.black, lineWidth: 4)
            .frame(width: totalWidth, height: totalHeight)
    }

    var body: some View {
        ZStack {
            background
            mazeGrid
        }
        .overlay(borderOverlay)
        .onChange(of: showSolution) { _, newVal in
            if newVal {
                animateSolutionPathReveal()
            } else {
                cancelAndReset()
            }
        }
        .onChange(of: cells) { _, _ in
            cancelAndReset()
        }
        .onAppear {
            if showSolution {
                animateSolutionPathReveal()
            }
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

        let pathCoords = cells
            .filter { $0.onSolutionPath && !$0.isVisited }
            .sorted { $0.distance < $1.distance }
            .map { Coordinates(x: $0.x, y: $0.y) }

        let baseDelay: Double = 0.015
        let speedFactor = min(1.0, cellSize / 50.0)
        let interval = baseDelay * speedFactor

        for (i, coord) in pathCoords.enumerated() {
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

//import SwiftUI
//import AudioToolbox
//import UIKit  // for UIFeedbackGenerator
//
//struct OrthogonalMazeView: View {
//    @Binding var selectedPalette: HeatMapPalette
//    let cells: [MazeCell]
//    let showSolution: Bool
//    let showHeatMap: Bool
//    let defaultBackgroundColor: Color
//
//    @State private var revealedSolutionPath: Set<Coordinates> = []
//    @State private var pendingWorkItems: [DispatchWorkItem] = []
//
//    private let columns: [GridItem]
//    private let cellSize: CGFloat
//    private let maxDistance: Int
//
//    private let haptic = UIImpactFeedbackGenerator(style: .light)
//
//    @Environment(\.colorScheme) private var colorScheme // Access the color scheme
//
//    init(
//        selectedPalette: Binding<HeatMapPalette>,
//        cells: [MazeCell],
//        showSolution: Bool,
//        showHeatMap: Bool,
//        defaultBackgroundColor: Color
//    ) {
//        self._selectedPalette = selectedPalette
//        self.cells = cells
//        self.showSolution = showSolution
//        self.showHeatMap = showHeatMap
//        self.defaultBackgroundColor = defaultBackgroundColor
//
//        let cols = (cells.map(\.x).max() ?? 0) + 1
//        self.columns = Array(
//            repeating: GridItem(.flexible(), spacing: 0),
//            count: cols
//        )
//
//        let screenW = UIScreen.main.bounds.width
//        let rawSize = screenW / CGFloat(cols)
//        let scale = UIScreen.main.scale
//        self.cellSize = (rawSize * scale).rounded() / scale
//
//        self.maxDistance = cells.map(\.distance).max() ?? 1
//    }
//
//    // Computed property for total width
//    private var totalWidth: CGFloat {
//        let cols = (cells.map(\.x).max() ?? 0) + 1
//        return cellSize * CGFloat(cols)
//    }
//
//    // Computed property for total height
//    private var totalHeight: CGFloat {
//        let rows = (cells.map(\.y).max() ?? 0) + 1
//        return cellSize * CGFloat(rows)
//    }
//
//    // Background view
//    private var background: some View {
//        (colorScheme == .dark ? Color.black : CellColors.offWhite)
//            .frame(width: totalWidth, height: totalHeight)
//    }
//
//    // Maze grid view
//    private var mazeGrid: some View {
//        LazyVGrid(columns: columns, spacing: 0) {
//            ForEach(cells.indices, id: \.self) { i in
//                cellView(for: i)
//            }
//        }
//        .drawingGroup()  // Batch offscreen rendering
//    }
//
//    // Cell view builder
//    @ViewBuilder
//    private func cellView(for index: Int) -> some View {
//        let cell = cells[index]
//        let coord = Coordinates(x: cell.x, y: cell.y)
//        OrthogonalCellView(
//            cell: cell,
//            cellSize: cellSize,
//            showSolution: showSolution,
//            showHeatMap: showHeatMap,
//            selectedPalette: selectedPalette,
//            maxDistance: maxDistance,
//            isRevealedSolution: revealedSolutionPath.contains(coord),
//            defaultBackgroundColor: defaultBackgroundColor
//        )
//        .frame(width: cellSize, height: cellSize)
//    }
//
//    // Border overlay view
//    private var borderOverlay: some View {
//        Rectangle()
//            .stroke(Color.black, lineWidth: 4)
//            .frame(width: totalWidth, height: totalHeight)
//    }
//
//    var body: some View {
//        ZStack {
//            background
//            mazeGrid
//        }
//        .overlay(borderOverlay)
//        .onChange(of: showSolution) { _, newVal in
//            if newVal {
//                animateSolutionPathReveal()
//            } else {
//                cancelAndReset()
//            }
//        }
//        .onChange(of: cells) { _, _ in
//            cancelAndReset()
//        }
//        .onAppear {
//            if showSolution {
//                animateSolutionPathReveal()
//            }
//        }
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
//        haptic.prepare()
//
//        let pathCoords = cells
//            .filter { $0.onSolutionPath && !$0.isVisited }
//            .sorted { $0.distance < $1.distance }
//            .map { Coordinates(x: $0.x, y: $0.y) }
//
//        let baseDelay: Double = 0.015
//        let speedFactor = min(1.0, cellSize / 50.0)
//        let interval = baseDelay * speedFactor
//
//        for (i, coord) in pathCoords.enumerated() {
//            let work = DispatchWorkItem {
//                AudioServicesPlaySystemSound(1104)
//                haptic.impactOccurred()
//                withAnimation(.none) {
//                    _ = revealedSolutionPath.insert(coord)
//                }
//            }
//            pendingWorkItems.append(work)
//            DispatchQueue.main.asyncAfter(
//                deadline: .now() + Double(i) * interval,
//                execute: work
//            )
//        }
//    }
//}
