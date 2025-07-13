import SwiftUI
import AudioToolbox
import UIKit

struct RhombicMazeView: View {
    @Binding var selectedPalette: HeatMapPalette
    let cells: [MazeCell]
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let defaultBackgroundColor: Color
    let optionalColor: Color?

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []

    private let maxDistance: Int
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Precomputed constants
    private let sqrt2: CGFloat = CGFloat(2).squareRoot()
    private var diagonal: CGFloat { cellSize * sqrt2 }
    private var halfDiagonal: CGFloat { diagonal / 2 }

    private var maxX: CGFloat { CGFloat(cells.map(\.x).max() ?? 0) }
    private var maxY: CGFloat { CGFloat(cells.map(\.y).max() ?? 0) }

    private var containerWidth: CGFloat {
        halfDiagonal * maxX + diagonal
    }
    private var containerHeight: CGFloat {
        halfDiagonal * maxY + diagonal
    }

    private var totalRows: Int {
        Int(maxY) + 1
    }

    init(
        selectedPalette: Binding<HeatMapPalette>,
        cells: [MazeCell],
        cellSize: CGFloat,
        showSolution: Bool,
        showHeatMap: Bool,
        defaultBackgroundColor: Color,
        optionalColor: Color?
    ) {
        self._selectedPalette = selectedPalette
        self.cells = cells
        self.cellSize = cellSize
        self.showSolution = showSolution
        self.showHeatMap = showHeatMap
        self.defaultBackgroundColor = defaultBackgroundColor
        self.optionalColor = optionalColor
        self.maxDistance = cells.map(\.distance).max() ?? 1
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            cellsOverlay
        }
        .frame(
            width:  containerWidth,
            height: containerHeight,
        )
        .onChange(of: showSolution, perform: handleShowSolutionChange)
        .onChange(of: cells) { _ in cancelAndReset() }
        .onAppear { if showSolution { animateSolutionPathReveal() } }
    }

    // MARK: - Grid construction

    @ViewBuilder
    private var cellsOverlay: some View {
        ForEach(cells, id: \.self) { cell in
            cellView(for: cell)
        }
    }
    
    private func cellView(for cell: MazeCell) -> some View {
        RhombicCellView(
            cell: cell,
            cellSize: cellSize,
            showSolution: showSolution,
            showHeatMap: showHeatMap,
            selectedPalette: selectedPalette,
            maxDistance: maxDistance,
            isRevealedSolution: revealedSolutionPath.contains(.init(x: cell.x, y: cell.y)),
            defaultBackgroundColor: defaultBackgroundColor,
            optionalColor: optionalColor,
            totalRows: totalRows
        )
        .offset(
            x: CGFloat(cell.x) * halfDiagonal,
            y: CGFloat(cell.y) * halfDiagonal
        )
    }

    // MARK: - Handlers

    private func handleShowSolutionChange(_ newValue: Bool) {
        if newValue { animateSolutionPathReveal() }
        else      { cancelAndReset() }
    }

    private func cancelAndReset() {
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        revealedSolutionPath.removeAll()
    }

    private func animateSolutionPathReveal() {
        cancelAndReset()
        haptic.prepare()

        let pathCells = cells
            .filter { $0.onSolutionPath && !$0.isVisited }
            .sorted { $0.distance < $1.distance }

        let baseDelay: Double   = 0.015
        let speedFactor         = min(1.0, cellSize / 50.0)
        let interval            = baseDelay * speedFactor

        for (i, cell) in pathCells.enumerated() {
            let coord = Coordinates(x: cell.x, y: cell.y)
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

