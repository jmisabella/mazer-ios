//
//  HexDirection.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/27/25.
//

import SwiftUI

enum HexDirection: String, CaseIterable, Hashable {
    case up           = "Up"
    case upperRight   = "UpperRight"
    case lowerRight   = "LowerRight"
    case down         = "Down"
    case lowerLeft    = "LowerLeft"
    case upperLeft    = "UpperLeft"
}

extension HexDirection {
    /// Reuse for your control buttons if you like:
    var systemImage: String {
        switch self {
        case .up:          return "arrow.up"
        case .down:        return "arrow.down"
        case .upperLeft:   return "arrow.up.left"
        case .upperRight:  return "arrow.up.right"
        case .lowerLeft:   return "arrow.down.left"
        case .lowerRight:  return "arrow.down.right"
        }
    }

    /// Which two points[] indices form this edge in your Path:
    var vertexIndices: (start: Int, end: Int) {
        switch self {
        case .up:          return (0, 1)
        case .upperRight:  return (1, 2)
        case .lowerRight:  return (2, 3)
        case .down:        return (3, 4)
        case .lowerLeft:   return (4, 5)
        case .upperLeft:   return (5, 0)
        }
    }

    /// Opposite direction (for optional bidirectional sanity checks)
    var opposite: HexDirection {
        switch self {
        case .up:          return .down
        case .upperRight:  return .lowerLeft
        case .lowerRight:  return .upperLeft
        case .down:        return .up
        case .lowerLeft:   return .upperRight
        case .upperLeft:   return .lowerRight
        }
    }

    /// (Optional) axial offsets if you ever switch to an axial coordinate system.
    /// You can ignore this if you stick with your current offset-grid math.
    var delta: (dq: Int, dr: Int) {
        switch self {
        case .up:          return (0, -1)
        case .upperRight:  return (1, -1)
        case .lowerRight:  return (1,  0)
        case .down:        return (0,  1)
        case .lowerLeft:   return (-1, 1)
        case .upperLeft:   return (-1, 0)
        }
    }
    
    /// Offsets for an “odd-q vertical” layout:
    ///   even columns: northEast=(+1,-1), southEast=(+1,0), etc.
    ///   odd  columns: northEast=(+1, 0), southEast=(+1,+1), etc.
    func offsetDelta(isOddColumn: Bool) -> (dq: Int, dr: Int) {
        switch (self, isOddColumn) {
        case (.up,        _):     return ( 0, -1)
        case (.upperRight,   false):  return ( 1, -1)
        case (.upperRight,    true):  return ( 1,  0)
        case (.lowerRight,   false):  return ( 1,  0)
        case (.lowerRight,    true):  return ( 1,  1)
        case (.down,        _):     return ( 0,  1)
        case (.lowerLeft,   false):  return (-1,  0)
        case (.lowerLeft,    true):  return (-1,  1)
        case (.upperLeft,   false):  return (-1, -1)
        case (.upperLeft,    true):  return (-1,  0)
        }
    }
}
