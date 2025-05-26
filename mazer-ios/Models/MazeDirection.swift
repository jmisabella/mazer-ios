//
//  MazeDirection.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/21/25.
//

import SwiftUI

// 1) Define a small enum or alias for clarity:
enum MazeDirection: String, CaseIterable, Hashable {
    //  case up, down, left, right
    //  case upperLeft, upperRight, lowerLeft, lowerRight
    case up = "Up"
    case down = "Down"
    case left = "Left"
    case right = "Right"
    case upperLeft = "UpperLeft"
    case upperRight = "UpperRight"
    case lowerLeft = "LowerLeft"
    case lowerRight = "LowerRight"
}

// 2) Map each to its SF Symbol:
extension MazeDirection {
  var systemImage: String {
    switch self {
    case .up:          return "arrow.up"
    case .down:        return "arrow.down"
    case .left:        return "arrow.left"
    case .right:       return "arrow.right"
    case .upperLeft:   return "arrow.up.left"
    case .upperRight:  return "arrow.up.right"
    case .lowerLeft:   return "arrow.down.left"
    case .lowerRight:  return "arrow.down.right"
    }
  }
    
}

// Extension for Rust FFI codes, aligned with Rust Direction
extension MazeDirection {
    var code: UInt32 {
        switch self {
        case .up:          return 0
        case .right:       return 1
        case .down:        return 2
        case .left:        return 3
        case .upperRight:  return 4
        case .lowerRight:  return 5
        case .lowerLeft:   return 6
        case .upperLeft:   return 7
        }
    }
}
