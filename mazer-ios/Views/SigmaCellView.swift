//
//  HexCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/22/25.
//

import SwiftUI

struct SigmaCellView: View {
    // MARK: – Public API
    let allCells: [MazeCell] // TODO: REMOVE DEBUG LINE
    let cell: MazeCell
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color


    // MARK: – Private storage
    private let cellMap: [Coordinates: MazeCell]

    // MARK: – Init
    init(
        allCells: [MazeCell], // TODO: REMOVE DEBUG LINE
        cell: MazeCell,
        cellSize: CGFloat,
        showSolution: Bool,
        showHeatMap: Bool,
        selectedPalette: HeatMapPalette,
        maxDistance: Int,
        isRevealedSolution: Bool,
        defaultBackgroundColor: Color
    ) {
        self.cell = cell
        self.allCells = allCells
        self.cellSize = cellSize
        self.showSolution = showSolution
        self.showHeatMap = showHeatMap
        self.selectedPalette = selectedPalette
        self.maxDistance = maxDistance
        self.isRevealedSolution = isRevealedSolution
        self.defaultBackgroundColor = defaultBackgroundColor

        // build fast lookup by coordinate
        var m = [Coordinates: MazeCell]()
        for c in allCells {
            m[Coordinates(x: c.x, y: c.y)] = c
        }
        self.cellMap = m
    }

    // MARK: – Geometry helpers
    private var width: CGFloat { cellSize * 2 }
    private var height: CGFloat { cellSize * sqrt(3) }
    private func snap(_ x: CGFloat) -> CGFloat {
        let scale = UIScreen.main.scale
        return (x * scale).rounded() / scale
    }
    private var points: [CGPoint] {
        let s = cellSize, h = sqrt(3) * s
        return [
            CGPoint(x: snap(s * 0.5), y: snap(0)),    // top-left
            CGPoint(x: snap(s * 1.5), y: snap(0)),    // top-right
            CGPoint(x: snap(2 * s),    y: snap(h/2)), // mid-right
            CGPoint(x: snap(s * 1.5), y: snap(h)),    // bottom-right
            CGPoint(x: snap(s * 0.5), y: snap(h)),    // bottom-left
            CGPoint(x: snap(0),        y: snap(h/2)) // mid-left
        ]
    }

    // MARK: – Body
    var body: some View {
        ZStack {
            // 1) fill
            Path { p in
                p.addLines(points); p.closeSubpath()
            }
            .fill(cellBackgroundColor(
                for: cell,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                maxDistance: maxDistance,
                selectedPalette: selectedPalette,
                isRevealedSolution: isRevealedSolution,
                defaultBackground: defaultBackgroundColor
            ))

            // 2) walls with mismatch‐skip
            Path { p in
                for dir in HexDirection.allCases {
                    let linked       = cell.linked.contains(dir.rawValue)
                    // check neighbor’s reciprocal link:
                    let coord        = Coordinates(
                        x: cell.x + dir.delta.dq,
                        y: cell.y + dir.delta.dr
                    )
                    
                    let neighbor = cellMap[coord]
                    let neighborLink = cellMap[coord]?
                        .linked.contains(dir.opposite.rawValue) ?? false

                    // if there's a mismatch (one-way link) AND
                    // either this cell or its neighbor is start/goal, skip drawing
                    if linked != neighborLink &&
                        (cell.isStart || cell.isGoal ||
                         neighbor?.isStart == true || neighbor?.isGoal == true) {
                        continue
                    }

                    // otherwise draw the wall if not linked:
                    if !linked {
                        let (i, j) = dir.vertexIndices
                        p.move(to: points[i])
                        p.addLine(to: points[j])
                    }
                }
            }
            .stroke(
                Color.black,
                lineWidth: snap(cellStrokeWidth(for: cellSize, mazeType: .sigma))
            )
        }
        .frame(width: width, height: height)
        .compositingGroup()
        .drawingGroup(opaque: true, colorMode: .linear)
        .clipped(antialiased: false)
    }
}
