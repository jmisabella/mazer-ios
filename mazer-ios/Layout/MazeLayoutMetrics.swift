//
//  MazeLayoutUtils.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/13/25.
//

import SwiftUI

func computeCellSize(mazeCells: [MazeCell], mazeType: MazeType, cellSize: CellSize) -> CGFloat {
    let cols = (mazeCells.map { $0.x }.max() ?? 0) + 1
    let rows = (mazeCells.map { $0.y }.max() ?? 0) + 1
    switch mazeType {
    case .orthogonal:
        return UIScreen.main.bounds.width / CGFloat(cols)
    case .delta:
        return computeDeltaCellSize(cellSize: cellSize, columns: cols, rows: rows)
    case .sigma:
        let units = 1.5 * CGFloat(cols - 1) + 1
        return UIScreen.main.bounds.width / units
    case .rhombic:
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        let overhead: CGFloat = 150.0  // Match the value used in ContentView.swift
        let availableH = screenH - overhead
        let widthBased = screenW * sqrt(2.0) / (CGFloat(cols) + 1.0)
        let heightBased = availableH * sqrt(2.0) / (CGFloat(rows) + 1.0)
        return min(widthBased, heightBased)
    default:
        return UIScreen.main.bounds.width / CGFloat(cols)
    }
}

func adjustedCellSize(mazeType: MazeType, cellSize: CellSize) -> CGFloat {
    let adjustment: CGFloat = {
        switch mazeType {
        case .delta:
            switch cellSize {
            case .tiny: return 1.7
            case .small: return 2.0
            case .medium: return 2.23
            case .large: return 2.42
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
            case .tiny: return 2.35
            case .small: return 2.5
            case .medium: return 2.85
            case .large: return 3.3
            }
        case .rhombic:
            switch cellSize {
            case .tiny: return 1.45
            case .small: return 1.65
            case .medium: return 1.8
            case .large:
                let screenSize = UIScreen.main.bounds.size
                if screenSize.width == 440.0 && screenSize.height == 956.0 {
                    return 2.1
                } else if screenSize.width == 414.0 && screenSize.height == 896.0 {
                    return 2.1
                } else {
                    return 2.2
                }
            }
        }
    }()
    
    let rawSize = CGFloat(cellSize.rawValue)
//    return adjustment * rawSize
    var result = adjustment * rawSize
        
    if cellSize == .large && UIDevice.current.userInterfaceIdiom == .pad {
        result *= 1.5
    }
    return result
}

func computeVerticalPadding(mazeType: MazeType, cellSize: CellSize) -> CGFloat {
    let screenH = UIScreen.main.bounds.height
    let basePadding: CGFloat = {
        switch mazeType {
        case .delta: return 230
        case .orthogonal: return 140
        case .sigma: return 280
        case .upsilon: return 0
        case .rhombic: return 0
        }
    }()
    let sizeRatio: CGFloat = {
        switch cellSize {
        case .tiny: return 0.35
        case .small: return 0.30
        case .medium: return 0.25
        case .large: return 0.20
        }
    }()
    return min(basePadding, screenH * sizeRatio)
}

func computeCellSizes(mazeType: MazeType, cellSize: CellSize) -> (square: CGFloat, octagon: CGFloat) {
    let baseCellSize = adjustedCellSize(mazeType: mazeType, cellSize: cellSize)
    if mazeType == .upsilon {
        let octagonCellSize = baseCellSize
        let squareCellSize = octagonCellSize * (sqrt(2) - 1)
        return (square: squareCellSize, octagon: octagonCellSize)
    } else {
        return (square: baseCellSize, octagon: baseCellSize)
    }
}

func computeDeltaCellSize(cellSize: CellSize, columns: Int, rows: Int, screenWidth: CGFloat = UIScreen.main.bounds.width, screenHeight: CGFloat = UIScreen.main.bounds.height) -> CGFloat {
    let padding: CGFloat = 0.0  // Set to 0 to maximize width; adjust if overflow occurs on specific devices
    let availableW = screenWidth - padding * 2
    let overhead: CGFloat = 150.0  // Match the value used in ContentView.swift
    let availableH = screenHeight - overhead
    
    let widthBased = availableW * 2 / (CGFloat(columns) + 1)
    let heightBased = availableH * 2 / (CGFloat(rows) * sqrt(3.0))
    
    return min(widthBased, heightBased)
}

func navigationMenuVerticalAdjustment(mazeType: MazeType, cellSize: CellSize) -> CGFloat {
    let paddingMap: [(width: CGFloat, height: CGFloat, mazeType: MazeType, cellSize: CellSize, padding: CGFloat)] = [
        // iPhone SE 2nd gen, SE 3rd gen RHOMBIC MAZE TYPE REJECTED FOR SE
//        (width: 375.0, height: 667.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -99.0),
        // iPhone Xs, 11 Pro, 12 mini, 13 mini
        (width: 375.0, height: 812.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -3.0),
        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
        (width: 390.0, height: 844.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -9.0),
        // iPhone 14 Pro, 15, 15 Pro
        (width: 393.0, height: 852.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -10.0),
        // iPhone 16 Pro
        (width: 402.0, height: 874.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -11.0),
        // iPhone Xr, Xs Max, 11, 11 Pro Max
        (width: 414.0, height: 896.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -14.0),
        // iPhone 12 Pro Max, 13 Pro Max
        (width: 428.0, height: 926.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -16.0),
        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
        (width: 430.0, height: 932.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -20.0),
        // iPhone 16 Pro Max
        (width: 440.0, height: 956.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -24.0),
        ///
        // iPhone SE 2nd gen, SE 3rd gen RHOMBIC MAZE TYPE REJECTED FOR SE
//        (width: 375.0, height: 667.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -99.0),
        // iPhone Xs, 11 Pro, 12 mini, 13 mini
        (width: 375.0, height: 812.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -3.0),
        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
        (width: 390.0, height: 844.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -9.0),
        // iPhone 14 Pro, 15, 15 Pro
        (width: 393.0, height: 852.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -10.0),
        // iPhone 16 Pro
        (width: 402.0, height: 874.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -11.0),
        // iPhone Xr, Xs Max, 11, 11 Pro Max
        (width: 414.0, height: 896.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -14.0),
        // iPhone 12 Pro Max, 13 Pro Max
        (width: 428.0, height: 926.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -16.0),
        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
        (width: 430.0, height: 932.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -17.0),
        // iPhone 16 Pro Max
        (width: 440.0, height: 956.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -24.0),
        ///
        // iPhone SE 2nd gen, SE 3rd gen RHOMBIC MAZE TYPE REJECTED FOR SE
//        (width: 375.0, height: 667.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -99.0),
        // iPhone Xs, 11 Pro, 12 mini, 13 mini
        (width: 375.0, height: 812.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -14.0),
        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
        (width: 390.0, height: 844.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -12.0),
        // iPhone 14 Pro, 15, 15 Pro
        (width: 393.0, height: 852.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -14.0),
        // iPhone 16 Pro
        (width: 402.0, height: 874.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -11.0),
        // iPhone Xr, Xs Max, 11, 11 Pro Max
        (width: 414.0, height: 896.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -24.0),
        // iPhone 12 Pro Max, 13 Pro Max
        (width: 428.0, height: 926.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -22.0),
        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
        (width: 430.0, height: 932.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -21.0),
        // iPhone 16 Pro Max
        (width: 440.0, height: 956.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -29.0),
        ///
        // iPhone SE 2nd gen, SE 3rd gen RHOMBIC MAZE TYPE REJECTED FOR SE
//        (width: 375.0, height: 667.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -99.0),
        // iPhone Xs, 11 Pro, 12 mini, 13 mini
        (width: 375.0, height: 812.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -14.0),
        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
        (width: 390.0, height: 844.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -12.0),
        // iPhone 14 Pro, 15, 15 Pro
        (width: 393.0, height: 852.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -14.0),
        // iPhone 16 Pro
        (width: 402.0, height: 874.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -16.0),
        // iPhone Xr, Xs Max, 11, 11 Pro Max
        (width: 414.0, height: 896.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -26.0),
        // iPhone 12 Pro Max, 13 Pro Max
        (width: 428.0, height: 926.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -26.0),
        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
        (width: 430.0, height: 932.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -24.0),
        // iPhone 16 Pro Max
        (width: 440.0, height: 956.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -30.0),
    ]
    let screenSize = UIScreen.main.bounds.size
//    print("Screen dimensions: width = \(screenSize.width), height = \(screenSize.height)")
    
    if mazeType == .rhombic {
        for entry in paddingMap {
            if entry.mazeType == mazeType &&
               entry.cellSize == cellSize &&
               entry.width == screenSize.width &&
               entry.height == screenSize.height {
                return entry.padding
            }
        }
    }
    
    return 0
}

func navigationMenuHorizontalAdjustment(mazeType: MazeType, cellSize: CellSize) -> CGFloat {
    let paddingMap: [(width: CGFloat, height: CGFloat, mazeType: MazeType, cellSize: CellSize, padding: CGFloat)] = [
        // iPhone 16 Pro Max
        (width: 440.0, height: 956.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: 6.0),
    ]
    let screenSize = UIScreen.main.bounds.size
//    print("Screen dimensions: width = \(screenSize.width), height = \(screenSize.height)")
    
    if mazeType == .rhombic {
        for entry in paddingMap {
            if entry.mazeType == mazeType &&
               entry.cellSize == cellSize &&
               entry.width == screenSize.width &&
               entry.height == screenSize.height {
                return entry.padding
            }
        }
    }
    return 0
}
