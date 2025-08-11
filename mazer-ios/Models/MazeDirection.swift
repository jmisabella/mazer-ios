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
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        case .upperLeft: return "arrow.up.left"
        case .upperRight: return "arrow.up.right"
        case .lowerLeft: return "arrow.down.left"
        case .lowerRight: return "arrow.down.right"
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
