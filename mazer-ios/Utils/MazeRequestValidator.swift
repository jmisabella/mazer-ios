import Foundation

struct MazeRequestValidator {
    static func validate(mazeType: String, width: Int, height: Int, algorithm: String, start_x: Int, start_y: Int, goal_x: Int, goal_y: Int) -> Result<String, MazeRequestError> {
        
        // Ensure width and height are valid
        guard width > 0, height > 0 else {
            return .failure(.invalidDimensions)
        }

        // Ensure start and goal coordinates are inside the grid
        guard (0..<width).contains(start_x), (0..<height).contains(start_y),
              (0..<width).contains(goal_x), (0..<height).contains(goal_y) else {
            return .failure(.invalidDimensions)
        }

        // Ensure start and goal coordinates are different
        guard (start_x, start_y) != (goal_x, goal_y) else {
            return .failure(.invalidDimensions)
        }

        // Construct the MazeRequest object
        let mazeRequest = MazeRequest(maze_type: MazeType(rawValue: mazeType) ?? MazeType.orthogonal, width: width, height: height, algorithm: MazeAlgorithm(rawValue: algorithm) ?? MazeAlgorithm.recursiveBacktracker, start: Coordinates(x: start_x, y: start_y), goal: Coordinates(x: goal_x, y: goal_y))

        // Encode as JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(mazeRequest)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return .success(jsonString)
            } else {
                return .failure(.invalidMazeRequestJSON)
            }
        } catch {
            return .failure(.invalidMazeRequestJSON)
        }
    }
}

