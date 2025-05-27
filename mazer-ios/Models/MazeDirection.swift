//
//  MazeDirection.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/21/25.
//

import SwiftUI

// 1) Define a small enum or alias for clarity:
enum MazeDirection: String, CaseIterable, Hashable {
  case up, down, left, right
  case upperLeft, upperRight, lowerLeft, lowerRight
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
