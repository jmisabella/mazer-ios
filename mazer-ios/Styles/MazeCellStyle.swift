//
//  MazeCellStyle.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

func wallStrokeWidth(for mazeType: MazeType, cellSize: CGFloat) -> CGFloat {
//    print("Cell size: \(cellSize)") 
    let denominator: CGFloat
    switch mazeType {
    case .delta:
        denominator = cellSize >= 28 ? 10 : 12
    case .orthogonal:
        denominator = cellSize >= 18 ? 6 : 6
    case .sigma:
        denominator = cellSize >= 18 ? 6 : 7
    case .upsilon:
        denominator = cellSize >= 28 ? 12 : 16
    case .rhombic:
        denominator = cellSize >= 18 ? 7 : 4.8
    }
    
    let raw = cellSize / denominator
    let scale = UIScreen.main.scale
    let snapped = (raw * scale).rounded() / scale
    if mazeType == .delta {
        let adjusted = snapped * 1.15
        return (adjusted * scale).rounded() / scale
    } else {
        return snapped
    }
}

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

func adjustedCellSize(mazeType: MazeType, cellSize: CellSize) -> CGFloat {
    let adjustment: CGFloat = {
        switch mazeType {
        case .delta:
            switch cellSize {
            case .tiny: return 1.07
            case .small: return 1.36
            case .medium: return 1.47
            case .large: return 1.6
            }
        case .orthogonal:
            switch cellSize {
            case .tiny: return 1.2
            case .small: return 1.3
            case .medium: return 1.65
            case .large: return 1.8
            }
        case .sigma:
            switch cellSize {
            case .tiny: return 0.5
            case .small: return 0.65
            case .medium: return 0.75
            case .large: return 0.8
            }
        case .upsilon:
            switch cellSize {
            case .tiny: return 2.3
            case .small: return 2.4
            case .medium: return 2.5
            case .large: return 3.3
            }
        case .rhombic:
            switch cellSize {
            case .tiny: return 0.75
            case .small: return 0.9
            case .medium: return 1.2
            case .large: return 1.5
            }
        }
    }()
    
    let rawSize = CGFloat(cellSize.rawValue)
    return adjustment * rawSize
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


