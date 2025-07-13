//
//  MazeLayoutUtils.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/13/25.
//

import SwiftUI

func computeCellSize(mazeCells: [MazeCell], mazeType: MazeType, cellSize: CellSize) -> CGFloat {
    let cols = (mazeCells.map { $0.x }.max() ?? 0) + 1
    switch mazeType {
    case .orthogonal:
        return UIScreen.main.bounds.width / CGFloat(cols)
    case .delta:
        return computeDeltaCellSize(cellSize: cellSize, columns: cols)
    case .sigma:
        let units = 1.5 * CGFloat(cols - 1) + 1
        return UIScreen.main.bounds.width / units
    default:
        return UIScreen.main.bounds.width / CGFloat(cols)
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
            case .tiny: return 2.35
            case .small: return 2.5
            case .medium: return 2.85
            case .large: return 3.3
            }
        case .rhombic:
            switch cellSize {
            case .tiny: return 0.75
            case .small: return 0.9
            case .medium: return 1.2
            case .large:
                let screenSize = UIScreen.main.bounds.size
                if screenSize.width == 440.0 && screenSize.height == 956.0 {
                    return 1.4
                } else {
                    return 1.5
                }
            }
        }
    }()
    
    let rawSize = CGFloat(cellSize.rawValue)
    return adjustment * rawSize
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

//func computeDeltaCellSize(cellSize: CellSize, columns: Int, screenWidth: CGFloat = UIScreen.main.bounds.width, screenHeight: CGFloat = UIScreen.main.bounds.height) -> CGFloat {
////    print("Screen dimensions: \(screenWidth) x \(screenHeight)")
//    
//    // Define a map of (screenWidth, screenHeight, cellSize) to padding
//    let paddingMap: [(width: CGFloat, height: CGFloat, cellSize: CellSize, padding: CGFloat)] = [
//        // iPhone SE 2nd gen, SE 3rd gen
//        (width: 375.0, height: 667.0, cellSize: .tiny, padding: 46.0),
//        // iPhone SE 2nd gen, SE 3rd gen
//        (width: 375.0, height: 667.0, cellSize: .small, padding: 46.0),
//        // iPhone SE 2nd gen, SE 3rd gen
//        (width: 375.0, height: 667.0, cellSize: .medium, padding: 46.0),
//        // iPhone SE 2nd gen, SE 3rd gen
//        (width: 375.0, height: 667.0, cellSize: .large, padding: 46.0),
//        // iPhone Xs, 11 Pro, 12 mini, 13 mini
//        (width: 375.0, height: 812.0, cellSize: .tiny, padding: 34.0),
//        // iPhone Xs, 11 Pro, 12 mini, 13 mini
//        (width: 375.0, height: 812.0, cellSize: .small, padding: 34.0),
//        // iPhone Xs, 11 Pro, 12 mini, 13 mini
//        (width: 375.0, height: 812.0, cellSize: .medium, padding: 34.0),
//        // iPhone Xs, 11 Pro, 12 mini, 13 mini
//        (width: 375.0, height: 812.0, cellSize: .large, padding: 34.0),
//        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
//        (width: 390.0, height: 844.0, cellSize: .tiny, padding: 40.0),
//        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
//        (width: 390.0, height: 844.0, cellSize: .small, padding: 40.0),
//        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
//        (width: 390.0, height: 844.0, cellSize: .medium, padding: 40.0),
//        // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
//        (width: 390.0, height: 844.0, cellSize: .large, padding: 40.0),
//        // iPhone 14 Pro, 15, 15 Pro
//        (width: 393.0, height: 852.0, cellSize: .tiny, padding: 43.0),
//        // iPhone 14 Pro, 15, 15 Pro
//        (width: 393.0, height: 852.0, cellSize: .small, padding: 43.0),
//        // iPhone 14 Pro, 15, 15 Pro
//        (width: 393.0, height: 852.0, cellSize: .medium, padding: 43.0),
//        // iPhone 14 Pro, 15, 15 Pro
//        (width: 393.0, height: 852.0, cellSize: .large, padding: 43.0),
//        // iPhone 16 Pro
//        (width: 402.0, height: 875.0, cellSize: .tiny, padding: 41.0),
//        // iPhone 16 Pro
//        (width: 402.0, height: 875.0, cellSize: .small, padding: 41.0),
//        // iPhone 16 Pro
//        (width: 402.0, height: 875.0, cellSize: .medium, padding: 41.0),
//        // iPhone 16 Pro
//        (width: 402.0, height: 875.0, cellSize: .large, padding: 41.0),
//        // iPhone Xr, Xs Max, 11, 11 Pro Max
//        (width: 414.0, height: 896.0, cellSize: .tiny, padding: 45.0),
//        // iPhone Xr, Xs Max, 11, 11 Pro Max
//        (width: 414.0, height: 896.0, cellSize: .small, padding: 45.0),
//        // iPhone Xr, Xs Max, 11, 11 Pro Max
//        (width: 414.0, height: 896.0, cellSize: .medium, padding: 45.0),
//        // iPhone Xr, Xs Max, 11, 11 Pro Max
//        (width: 414.0, height: 896.0, cellSize: .large, padding: 45.0),
//        // iPhone 12 Pro Max, 13 Pro Max
//        (width: 428.0, height: 926.0, cellSize: .tiny, padding: 51.0),
//        // iPhone 12 Pro Max, 13 Pro Max
//        (width: 428.0, height: 926.0, cellSize: .small, padding: 51.0),
//        // iPhone 12 Pro Max, 13 Pro Max
//        (width: 428.0, height: 926.0, cellSize: .medium, padding: 51.0),
//        // iPhone 12 Pro Max, 13 Pro Max
//        (width: 428.0, height: 926.0, cellSize: .large, padding: 51.0),
//        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
//        (width: 430.0, height: 932.0, cellSize: .tiny, padding: 52.0),
//        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
//        (width: 430.0, height: 932.0, cellSize: .small, padding: 52.0),
//        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
//        (width: 430.0, height: 932.0, cellSize: .medium, padding: 52.0),
//        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
//        (width: 430.0, height: 932.0, cellSize: .large, padding: 52.0),
//        // iPhone 16 Pro Max
//        (width: 440.0, height: 956.0, cellSize: .tiny, padding: 53.0),
//        // iPhone 16 Pro Max
//        (width: 440.0, height: 956.0, cellSize: .small, padding: 53.0),
//        // iPhone 16 Pro Max
//        (width: 440.0, height: 956.0, cellSize: .medium, padding: 53.0),
//        // iPhone 16 Pro Max
//        (width: 440.0, height: 956.0, cellSize: .large, padding: 53.0),
//    ]
//    
//    // Find the closest match based on width and height for the given cellSize
//    let filteredMap = paddingMap.filter { $0.cellSize == cellSize }
//    var closestPadding: CGFloat = 0.0
//    var minDistance: CGFloat = .greatestFiniteMagnitude
//    
//    for entry in filteredMap {
//        let distance = abs(screenWidth - entry.width) + abs(screenHeight - entry.height)
//        if distance < minDistance {
//            minDistance = distance
//            closestPadding = entry.padding
//        }
//    }
//    
//    // Determine padding: use closest match if within threshold, else fallback
//    let padding: CGFloat
//    if minDistance < 50.0 {
//        padding = closestPadding
//    } else {
//        // Fallback: 10% of screen width
//        padding = screenWidth * 0.1
//    }
//    
//    // Clamp padding to ensure maze is playable
//    let minPadding: CGFloat = 20.0              // Minimum to keep maze visible
//    let maxPadding: CGFloat = screenWidth * 0.15 // Maximum to avoid overcrowding
//    let clampedPadding = max(minPadding, min(padding, maxPadding))
//    
//    // Calculate available width and return cell size
//    let available = screenWidth - clampedPadding * 2
//    return available * 2 / (CGFloat(columns) + 1)
//}

func computeDeltaCellSize(cellSize: CellSize, columns: Int, screenWidth: CGFloat = UIScreen.main.bounds.width, screenHeight: CGFloat = UIScreen.main.bounds.height) -> CGFloat {
//    print("Screen dimensions: \(screenWidth) x \(screenHeight)")
    
    // Define a map of (screenWidth, screenHeight) toPillars to padding
    let paddingMap: [(width: CGFloat, height: CGFloat, padding: CGFloat)] = [
        (width: 375.0, height: 667.0, padding: 46.0),  // iPhone SE 2nd gen, SE 3rd gen
        (width: 375.0, height: 812.0, padding: 34.0),  // iPhone Xs, 11 Pro, 12 mini, 13 mini
        (width: 390.0, height: 844.0, padding: 40.0),  // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
        (width: 393.0, height: 852.0, padding: 43.0),  // iPhone 14 Pro, 15, 15 Pro
        (width: 402.0, height: 875.0, padding: 41.0),  // iPhone 16 Pro
        (width: 414.0, height: 896.0, padding: 45.0),  // iPhone Xr, Xs Max, 11, 11 Pro Max
        (width: 428.0, height: 926.0, padding: 51.0),  // iPhone 12 Pro Max, 13 Pro Max
        (width: 430.0, height: 932.0, padding: 52.0),  // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
        (width: 440.0, height: 956.0, padding: 53.0),  // iPhone 16 Pro Max
    ]
    
    // Find the closest match based on width and height
    var closestPadding: CGFloat = 0.0
    var minDistance: CGFloat = .greatestFiniteMagnitude
    
    for entry in paddingMap {
        let distance = abs(screenWidth - entry.width) + abs(screenHeight - entry.height)
        if distance < minDistance {
            minDistance = distance
            closestPadding = entry.padding
        }
    }
    
    // Determine padding: use closest match if within threshold, else fallback
    let padding: CGFloat
    if minDistance < 50.0 {
        padding = closestPadding
    } else {
        // Fallback: 10% of screen width
        padding = screenWidth * 0.1
    }
    
    // Clamp padding to ensure maze is playable
    let minPadding: CGFloat = 20.0              // Minimum to keep maze visible
    let maxPadding: CGFloat = screenWidth * 0.15 // Maximum to avoid overcrowding
    let clampedPadding = max(minPadding, min(padding, maxPadding))
    
    // Calculate available width and return cell size
    let available = screenWidth - clampedPadding * 2
    return available * 2 / (CGFloat(columns) + 1)
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
        (width: 402.0, height: 875.0, mazeType: MazeType.rhombic, cellSize: CellSize.tiny, padding: -10.0),
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
        (width: 402.0, height: 875.0, mazeType: MazeType.rhombic, cellSize: CellSize.small, padding: -10.0),
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
        (width: 402.0, height: 875.0, mazeType: MazeType.rhombic, cellSize: CellSize.medium, padding: -14.0),
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
        (width: 402.0, height: 875.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -16.0),
        // iPhone Xr, Xs Max, 11, 11 Pro Max
        (width: 414.0, height: 896.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -26.0),
        // iPhone 12 Pro Max, 13 Pro Max
        (width: 428.0, height: 926.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -28.0),
        // iPhone 14 Pro Max, 15 Pro Max, 15 Plus, 16 Plus
        (width: 430.0, height: 932.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -24.0),
        // iPhone 16 Pro Max
        (width: 440.0, height: 956.0, mazeType: MazeType.rhombic, cellSize: CellSize.large, padding: -30.0),
    ]
    let screenSize = UIScreen.main.bounds.size
    print("Screen dimensions: width = \(screenSize.width), height = \(screenSize.height)")
    
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
    print("Screen dimensions: width = \(screenSize.width), height = \(screenSize.height)")
    
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
