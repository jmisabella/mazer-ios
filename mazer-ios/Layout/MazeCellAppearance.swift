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
        return CellColors.traversedPathColor
    } else if isRevealedSolution {
        return CellColors.solutionPathColor
    } else if showHeatMap && maxDistance > 0 {
        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    } else {
        return defaultBackground
    }
}

struct CellColors {
    static let vividBlue = Color(red: 104/255, green: 232/255, blue: 255/255)
    static let solutionPathColor = Color(
        red: (104 + 128) / 2 / 255,
        green: (232 + 128) / 2 / 255,
        blue: (255 + 128) / 2 / 255
    )
    static let traversedPathColor = Color(
        red: 255/255,
        green: 120/255,
        blue: 180/255
    )
    // Soft neutral gray
    static let defaultCellBackgroundGray = Color(
        red: 230/255,
        green: 230/255,
        blue: 230/255
    )
    // Pastel mint
    static let defaultCellBackgroundMint = Color(
        red: 200/255,
        green: 235/255,
        blue: 215/255
    )
    // Pastel peach
    static let defaultCellBackgroundPeach = Color(
        red: 255/255,
        green: 215/255,
        blue: 200/255
    )
    // Pastel lavender
    static let defaultCellBackgroundLavender = Color(
        red: 230/255,
        green: 220/255,
        blue: 245/255
    )
    // Pastel baby blue
    static let defaultCellBackgroundBlue = Color(
        red: 215/255,
        green: 230/255,
        blue: 255/255
    )
    static let defaultBackgroundColors: [Color] = [
        defaultCellBackgroundGray,
        defaultCellBackgroundMint,
        defaultCellBackgroundPeach,
        defaultCellBackgroundLavender,
        defaultCellBackgroundBlue
    ]
    // Moved from Color+Hex.swift
    static let solutionHighlight = Color(hex: "#04D9FF") // radiant neon blue!
    static let offWhite = Color(hex: "FFF5E6")
    static let orangeRed = Color(hex: "F66E6E")
    static let lightGrey = Color(hex: "333333")
    static let softOrange = Color(hex: "FFCCBC")
    static let lightSkyBlue = Color(hex: "ADD8E6")
    static let lightModeSecondary = Color(hex: "333333") // Consolidated with lightGrey
}
