

enum MazeRequestError: Error {
    case invalidMazeType
    case invalidDimensions
    case startAndGoalCoordinatesSame
    case invalidCoordinates
    case invalidAlgorithm
    case invalidMazeRequestJSON
}
