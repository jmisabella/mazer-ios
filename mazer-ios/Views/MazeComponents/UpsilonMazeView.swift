import SwiftUI
import AudioToolbox
import UIKit

struct GridSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct UpsilonMazeView: View {
    let cells: [MazeCell]
    let octagonSize: CGFloat
    let squareSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let defaultBackgroundColor: Color
    let optionalColor: Color?

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []
    @State private var gridSize: CGSize = .zero

    private var maxDistance: Int {
        cells.map(\.distance).max() ?? 1
    }

    private var columns: Int {
        (cells.map(\.x).max() ?? 0) + 1
    }

    private var rows: Int {
        (cells.map(\.y).max() ?? 0) + 1
    }

    private var horizontalSpacing: CGFloat {
        -(octagonSize - squareSize) / 2
    }

    private var verticalSpacing: CGFloat {
        -1
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(octagonSize), spacing: horizontalSpacing), count: columns)
    }

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        let totalRows = rows
        LazyVGrid(columns: gridColumns, spacing: verticalSpacing) {
            ForEach(cells, id: \.self) { cell in
                cellView(for: cell, totalRows: totalRows)
            }
        }
        .padding(.top, 10)
        .onChange(of: showSolution, perform: handleShowSolutionChange)
        .onChange(of: cells, perform: { _ in cancelAndReset() })
        .onAppear(perform: handleAppear)
    }

    private func cellView(for cell: MazeCell, totalRows: Int) -> some View {
        let coord = Coordinates(x: cell.x, y: cell.y)
        let fillColor = cellBackgroundColor(
            for: cell,
            showSolution: showSolution,
            showHeatMap: showHeatMap,
            maxDistance: maxDistance,
            selectedPalette: selectedPalette,
            isRevealedSolution: revealedSolutionPath.contains(coord),
            defaultBackground: defaultBackgroundColor,
            totalRows: totalRows,
            optionalColor: optionalColor
        )
        return UpsilonCellView(
            cell: cell,
            gridCellSize: octagonSize,
            squareSize: squareSize,
            isSquare: cell.isSquare,
            fillColor: fillColor,
            optionalColor: optionalColor
        )
        .frame(width: octagonSize, height: octagonSize * (sqrt(2) / 2))
    }

    private func handleShowSolutionChange(newValue: Bool) {
        if newValue {
            animateSolutionPathReveal()
        } else {
            cancelAndReset()
        }
    }

    private func handleAppear() {
        if showSolution {
            animateSolutionPathReveal()
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

        let pathCells = cells
            .filter { $0.onSolutionPath && !$0.isVisited }
            .sorted { $0.distance < $1.distance }

        let baseDelay: Double = 0.015
        let speedFactor = min(1.0, octagonSize / 50.0)
        let interval = baseDelay * speedFactor

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
