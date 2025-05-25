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

    // computed once
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

        // build grid columns
        let cols = (cells.map(\.x).max() ?? 0) + 1
        self.columns = Array(
            repeating: GridItem(.flexible(), spacing: 0),
            count: cols
        )

        // calculate cellSize once
//        let screenW = UIScreen.main.bounds.width
//        self.cellSize = screenW / CGFloat(cols)
        
        let screenW = UIScreen.main.bounds.width
        let rawSize = screenW / CGFloat(cols)
        let scale   = UIScreen.main.scale
        // round to whole‐pixel cell heights
        self.cellSize = (rawSize * scale).rounded() / scale


        // cache distances & stroke
        self.maxDistance = cells.map(\.distance).max() ?? 1
        let rawStroke = cellStrokeWidth(for: cellSize, mazeType: .orthogonal)
//        let scale = UIScreen.main.scale
        self.strokeWidth = (rawStroke * scale).rounded() / scale
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(cells.indices, id: \.self) { i in
                let cell = cells[i]
                let coord = Coordinates(x: cell.x, y: cell.y)
                OrthogonalCellView(
                    cell: cell,
                    cellSize: cellSize,
//                    size: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette,
                    maxDistance: maxDistance,
                    isRevealedSolution: revealedSolutionPath.contains(coord),
                    defaultBackgroundColor: defaultBackgroundColor//,
//                    strokeWidth: strokeWidth
                )
                .frame(width: cellSize, height: cellSize)
            }
        }
        .drawingGroup()  // batch offscreen rendering
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

        // compute the sorted path coordinates right here
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
