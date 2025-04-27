//
//  HexDirection.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/27/25.
//

enum HexDirection: String, CaseIterable {
  case Up, UpperRight, LowerRight, Down, LowerLeft, UpperLeft
    
    static let allCases: [HexDirection] = [
        .Up, .UpperRight, .LowerRight, .Down, .LowerLeft, .UpperLeft
    ]


  func neighbor(of cell: MazeCell) -> Coordinates {
    // treat (x,y) as axial (q,r)
    switch self {
    case .Up:         return .init(x: cell.x,     y: cell.y - 1)
    case .Down:       return .init(x: cell.x,     y: cell.y + 1)
    case .UpperRight: return .init(x: cell.x + 1, y: cell.y - 1)
    case .LowerRight: return .init(x: cell.x + 1, y: cell.y    )
    case .LowerLeft:  return .init(x: cell.x - 1, y: cell.y + 1)
    case .UpperLeft:  return .init(x: cell.x - 1, y: cell.y    )
    }
  }
}
