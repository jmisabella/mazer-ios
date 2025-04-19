//
//  MazeCellStyle.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

func cellBackgroundColor(
    for cell: MazeCell,
    showSolution: Bool,
    showHeatMap: Bool,
    maxDistance: Int,
    selectedPalette: HeatMapPalette,
    isRevealedSolution: Bool
) -> Color {
    if cell.isStart {
        return .blue
    } else if cell.isGoal {
        return .red
    } else if cell.isVisited {
        return .green
    } else if isRevealedSolution {
        return .solutionHighlight
    } else if showHeatMap && maxDistance > 0 {
        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    } else {
        return .white
    }
}

func cellStrokeWidth(for size: CGFloat) -> CGFloat {
    switch size {
    case ..<12:
        return 1.5
    case ..<13:
        return 2.0
    default:
        return 2.5
    }
}
