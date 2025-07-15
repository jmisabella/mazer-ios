//
//  MazeCellStyle.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

// Add this extension at the top of the file
extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        #if os(iOS)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif os(macOS)
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return (r, g, b, a)
    }
}

func interpolateColor(from start: Color, to end: Color, factor: Double) -> Color {
    let startComp = start.components
    let endComp = end.components
    let r = startComp.red + factor * (endComp.red - startComp.red)
    let g = startComp.green + factor * (endComp.green - startComp.green)
    let b = startComp.blue + factor * (endComp.blue - startComp.blue)
    let a = startComp.alpha + factor * (endComp.alpha - startComp.alpha)
    return Color(red: r, green: g, blue: b, opacity: a)
}

func wallStrokeWidth(for mazeType: MazeType, cellSize: CGFloat) -> CGFloat {
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

//func cellBackgroundColor(
//    for cell: MazeCell,
//    showSolution: Bool,
//    showHeatMap: Bool,
//    maxDistance: Int,
//    selectedPalette: HeatMapPalette,
//    isRevealedSolution: Bool,
//    defaultBackground: Color,
//    totalRows: Int,
//    optionalColor: Color?
//) -> Color {
//    if cell.isStart {
//        return .blue
//    } else if cell.isGoal {
//        return .red
//    } else if cell.isVisited {
//        return CellColors.traversedPathColor
//    } else if isRevealedSolution {
//        return CellColors.solutionPathColor
//    } else if showHeatMap && maxDistance > 0 {
//        let index = min(9, (cell.distance * 10) / maxDistance)
//        return selectedPalette.shades[index].asColor
//    } else {
//        if totalRows > 1 {
//            
//            let lightColor = interpolateColor(from: defaultBackground, to: .white, factor: 0.9) // subtle lightening
//            let randomColor = interpolateColor(from: defaultBackground, to: .pink, factor: 0.65) // subtle darkening
//            let startColor = useLightTheme ? lightColor : darkColor
//            let factor = Double(cell.y) / Double(totalRows - 1)
//            return interpolateColor(from: startColor, to: defaultBackground, factor: factor)
//        } else {
//            return defaultBackground
//        }
//    }
//}

func cellBackgroundColor(
    for cell: MazeCell,
    showSolution: Bool,
    showHeatMap: Bool,
    maxDistance: Int,
    selectedPalette: HeatMapPalette,
    isRevealedSolution: Bool,
    defaultBackground: Color,
    totalRows: Int,
    optionalColor: Color?
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
        if totalRows > 1 {
            let startColor: Color
            if let color = optionalColor {
//                startColor = interpolateColor(from: defaultBackground, to: color, factor: 0.2)
                startColor = interpolateColor(from: defaultBackground, to: color, factor: 0.17)
            } else {
                startColor = interpolateColor(from: defaultBackground, to: .white, factor: 0.9)
            }
            let factor = Double(cell.y) / Double(totalRows - 1)
            return interpolateColor(from: startColor, to: defaultBackground, factor: factor)
        } else {
            return defaultBackground
        }
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
    static let defaultCellBackgroundGray = Color(
        red: 230/255,
        green: 230/255,
        blue: 230/255
    )
    static let defaultCellBackgroundMint = Color(
        red: 200/255,
        green: 235/255,
        blue: 215/255
    )
    static let defaultCellBackgroundPeach = Color(
        red: 255/255,
        green: 215/255,
        blue: 200/255
    )
    static let defaultCellBackgroundLavender = Color(
        red: 230/255,
        green: 220/255,
        blue: 245/255
    )
    static let defaultCellBackgroundBlue = Color(
        red: 215/255,
        green: 230/255,
        blue: 255/255
    )
    static let defaultBackgroundColors: [Color] = [
        defaultCellBackgroundMint,
        defaultCellBackgroundPeach,
        offWhite,
        lighterSky,
        barelyLavenderMostlyWhite,
    ]
    static let solutionHighlight = Color(hex: "#04D9FF")
    static let offWhite = Color(hex: "FFF5E6")
    static let orangeRed = Color(hex: "F66E6E")
    static let lightGrey = Color(hex: "333333")
    static let softOrange = Color(hex: "FFCCBC")
    static let lightSkyBlue = Color(hex: "ADD8E6")
    static let lighterSky = Color(hex: "D6ECF3")
    static let grayerSky = Color(hex: "DAEDEF")
    static let lightModeSecondary = Color(hex: "333333")
    static let barelyLavenderMostlyWhite = Color(hex: "FAF9FB")
}
