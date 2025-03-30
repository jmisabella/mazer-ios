import Foundation

struct MazeRequest: Codable {
    let maze_type: MazeType
    let width: Int
    let height: Int
    let algorithm: MazeAlgorithm
    let start: Coordinates
    let goal: Coordinates
}
