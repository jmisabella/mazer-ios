//
//  OrthoSquareMazeView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/19/25.
//

import SwiftUI
import AudioToolbox
import UIKit

struct OctoSquareMazeView: View {
    let cells: [MazeCell]
    let octagonSize: CGFloat
    let squareSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let defaultBackgroundColor: Color

    @State private var revealedSolutionPath: Set<Coordinates> = []
    @State private var pendingWorkItems: [DispatchWorkItem] = []

    private var maxDistance: Int {
        cells.map(\.distance).max() ?? 1
    }

    private var columns: Int {
        (cells.map(\.x).max() ?? 0) + 1
    }

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        let horizontalSpacing = -(octagonSize - squareSize) / 2
        let verticalSpacing = horizontalSpacing // Start with same value, adjust if needed
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(octagonSize), spacing: horizontalSpacing), count: columns),
            spacing: verticalSpacing
        ) {
            ForEach(cells, id: \.self) { cell in
                let coord = Coordinates(x: cell.x, y: cell.y)
                OctoSquareCellView(
                    cell: cell,
                    gridCellSize: octagonSize,
                    squareSize: squareSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette,
                    maxDistance: maxDistance,
                    isRevealedSolution: revealedSolutionPath.contains(coord),
                    defaultBackgroundColor: defaultBackgroundColor
                )
                .frame(width: octagonSize, height: octagonSize * 0.71)
//                .frame(width: octagonSize, height: octagonSize)
            }
        }
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
