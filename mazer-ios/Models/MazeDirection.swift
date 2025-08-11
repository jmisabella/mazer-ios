//
//  MazeDirection.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/21/25.
//

import SwiftUI

enum MazeDirection: String, CaseIterable, Hashable {
    case up, down, left, right
    case upperLeft, upperRight, lowerLeft, lowerRight
    
    var systemImage: String {
        return "chevron.right" // Use a single chevron symbol for all directions
    }
    
    var rotation: Angle {
        switch self {
        case .right: return .degrees(0)
        case .lowerRight: return .degrees(45)
        case .down: return .degrees(90)
        case .lowerLeft: return .degrees(135)
        case .left: return .degrees(180)
        case .upperLeft: return .degrees(225)
        case .up: return .degrees(270)
        case .upperRight: return .degrees(315)
        }
    }
    
    var action: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .left: return "Left"
        case .right: return "Right"
        case .upperLeft: return "UpperLeft"
        case .upperRight: return "UpperRight"
        case .lowerLeft: return "LowerLeft"
        case .lowerRight: return "LowerRight"
        }
    }
}
