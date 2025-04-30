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
        return traversedPathColor
    } else if isRevealedSolution {
        return solutionPathColor
    } else if showHeatMap && maxDistance > 0 {
        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    } else {
        return .white
    }
}

let solutionPathColor = Color(
  red:   104/255,
  green: 232/255,
  blue: 255/255
)

let traversedPathColor = Color(
  red:   255/255,
  green: 120/255,
  blue:  180/255
)


//// soft pink
//let traversedPathColor = Color(
//  red:   255/255,
//  green: 182/255,
//  blue:  193/255
//)

func cellStrokeWidth(for size: CGFloat) -> CGFloat {
        switch size {
        case ..<12:
            return 2.5
        default:
            return 3.5
        }
//    switch size {
//    case ..<12:
//        return 2.5
//    case ..<13:
//        return 3.0
//    default:
//        return 2.0
//    }
}
