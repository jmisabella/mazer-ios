import Foundation

struct MazeRequest: Codable {
    let maze_type: MazeType
    let width: Int
    let height: Int
    let algorithm: MazeAlgorithm
    let capture_steps: Bool
    
    enum CodingKeys: String, CodingKey {
        case maze_type
        case width
        case height
        case algorithm
        case capture_steps
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maze_type.ffiName, forKey: .maze_type)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(algorithm, forKey: .algorithm)
        try container.encode(capture_steps, forKey: .capture_steps)
    }
}
