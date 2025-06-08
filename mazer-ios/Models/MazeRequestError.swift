import Foundation

enum MazeRequestError: Error, LocalizedError {
    case invalidMazeType
    case invalidDimensions
    case startAndGoalCoordinatesSame
    case invalidCoordinates
    case invalidAlgorithm
    case invalidDimensionsForCaptureSteps
    case invalidMazeRequestJSON
    
    var errorDescription: String? {
        switch self {
        case .invalidMazeType:
            return "The selected maze type is invalid."
        case .invalidDimensions:
            return "The provided maze dimensions are invalid."
        case .startAndGoalCoordinatesSame:
            return "Start and goal coordinates cannot be the same."
        case .invalidCoordinates:
            return "One or more coordinates are out of bounds."
        case .invalidAlgorithm:
            return "The selected algorithm is not valid for this maze type."
        case .invalidDimensionsForCaptureSteps:
            return "Capture steps is only available for mazes with width and height ≤ 100."
        case .invalidMazeRequestJSON:
            return "The maze request JSON is malformed."
        }
    }
}
