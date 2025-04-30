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

func cellStrokeWidth(for size: CGFloat, mazeType: MazeType) -> CGFloat {
    switch mazeType {
    case .orthogonal:
        switch size {
        case ..<8:
            let w: CGFloat = 1.5
            return w
        case 8..<14:
            let w: CGFloat = 3.0
            return w
        case 14..<18:
            let w: CGFloat = 3.5
            return w
        case 18..<24:
            let w: CGFloat = 4.5
            return w
        default:
            let w: CGFloat = 6.0
            return w
        }

    case .delta:
        switch size {
        case ..<8:
            let w: CGFloat = 1.5
            return w
        case 8..<14:
            let w: CGFloat = 2.5
            return w
        case 14..<18:
            let w: CGFloat = 2.5
            return w
        case 18..<24:
            let w: CGFloat = 3.0
            return w
        default:
            let w: CGFloat = 3.5
            return w
        }

    case .sigma:
        switch size {
        case ..<8:
            let w: CGFloat = 1.5
            return w
        case 8..<14:
            let w: CGFloat = 3.0
            return w
        case 14..<18:
            let w: CGFloat = 3.5
            return w
        case 18..<24:
            let w: CGFloat = 3.5
            return w
        default:
            let w: CGFloat = 4.5
            return w
        }

    // other MazeType cases...
    default:
        // fallback to orthogonal behavior
        return cellStrokeWidth(for: size, mazeType: .orthogonal)
    }
}

//// soft pink
//let traversedPathColor = Color(
//  red:   255/255,
//  green: 182/255,
//  blue:  193/255
//)
