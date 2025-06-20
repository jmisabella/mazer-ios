//
//  MazeLayoutUtils.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/13/25.
//

import SwiftUI

func computeCellSize(mazeCells: [MazeCell], mazeType: MazeType) -> CGFloat {
    let cols = (mazeCells.map { $0.x }.max() ?? 0) + 1
    switch mazeType {
    case .orthogonal:
        return UIScreen.main.bounds.width / CGFloat(cols)
    case .delta:
        return computeDeltaCellSize(columns: cols)
    case .sigma:
        let units = 1.5 * CGFloat(cols - 1) + 1
        return UIScreen.main.bounds.width / units
    default:
        return UIScreen.main.bounds.width / CGFloat(cols)
    }
}

func computeDeltaCellSize(columns: Int, screenWidth: CGFloat = UIScreen.main.bounds.width, screenHeight: CGFloat = UIScreen.main.bounds.height) -> CGFloat {
//    print("Screen dimensions: \(screenWidth) x \(screenHeight)")
    
    // Define a map of (screenWidth, screenHeight) toPillars to padding
    let paddingMap: [(width: CGFloat, height: CGFloat, padding: CGFloat)] = [
        (width: 375.0, height: 667.0, padding: 46.0),  // iPhone SE 2nd gen, SE 3rd gen
        (width: 375.0, height: 812.0, padding: 34.0),  // iPhone Xs, 11 Pro, 12 mini, 13 mini
        (width: 390.0, height: 844.0, padding: 38.0),  // iPhone 12, 12 Pro, 13, 13 Pro, 14, 16e
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

//func computeDeltaCellSize(columns: Int, screenWidth: CGFloat = UIScreen.main.bounds.width, screenHeight: CGFloat = UIScreen.main.bounds.height) -> CGFloat {
//    print("Screen dimensions: \(screenWidth) x \(screenHeight)")
//    
//    // Define a sorted array of (screenWidth, screenHeight, padding) tuples
//    let paddingMap: [(width: CGFloat, height: CGFloat, padding: CGFloat)] = [
////        (width: 375.0, height: 667.0, padding: 40.0),  // iPhone SE
//        (width: 375.0, height: 812.0, padding: 34.0),  // iPhone 11 Pro
//        (width: 390.0, height: 844.0, padding: 38.0),  // iPhone 16e
//        (width: 430.0, height: 932.0, padding: 52.0)   // iPhone 16 Plus
//    ]
//    
//    // Find the closest match based on width and height
//    var closestPadding: CGFloat = paddingMap.first!.padding
//    var minDistance: CGFloat = .greatestFiniteMagnitude
//    
//    for entry in paddingMap {
//        let distance = abs(screenWidth - entry.width) + abs(screenHeight - entry.height)
//        if distance < minDistance {
//            minDistance = distance
//            closestPadding = entry.padding
//        }
//    }
//    
//    let padding = closestPadding
//    
//    // Calculate available width and return cell size
//    let available = screenWidth - padding * 2
//    return available * 2 / (CGFloat(columns) + 1)
//}
//
//
