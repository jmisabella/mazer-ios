

enum MazeRequestError: Error {
    case invalidMazeType
    case invalidDimensions
    case invalidCoordinates
    case invalidAlgorithm
    case invalidMazeRequestJSON
}
