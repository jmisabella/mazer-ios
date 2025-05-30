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
    isRevealedSolution: Bool,
    defaultBackground: Color
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
        return defaultBackground
    }
}

let vividBlue = Color(red: 104/255, green: 232/255, blue: 255/255)
let solutionPathColor = Color(
  red:   (104 + 128) / 2 / 255,
  green: (232 + 128) / 2 / 255,
  blue:  (255 + 128) / 2 / 255
)

let traversedPathColor = Color(
  red:   255/255,
  green: 120/255,
  blue:  180/255
)

// Soft neutral gray
let defaultCellBackgroundGray = Color(
    red:   230/255,
    green: 230/255,
    blue: 230/255
)

// Pastel mint
let defaultCellBackgroundMint = Color(
    red:   200/255,
    green: 235/255,
    blue: 215/255
)

// Pastel peach
let defaultCellBackgroundPeach = Color(
    red:   255/255,
    green: 215/255,
    blue: 200/255
)

// Pastel lavender
let defaultCellBackgroundLavender = Color(
    red:   230/255,
    green: 220/255,
    blue: 245/255
)

// Pastel baby blue
let defaultCellBackgroundBlue = Color(
    red:   215/255,
    green: 230/255,
    blue: 255/255
)


let defaultBackgroundColors: [Color] = [
    defaultCellBackgroundGray,
    defaultCellBackgroundMint,
    defaultCellBackgroundPeach,
    defaultCellBackgroundLavender,
    defaultCellBackgroundBlue
]


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
            let w: CGFloat = 5
            return w
        default:
            let w: CGFloat = 5.0
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
