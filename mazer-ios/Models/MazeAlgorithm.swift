import Foundation

enum MazeAlgorithm: String, Codable {
    case binaryTree = "BinaryTree"
    case sidewinder = "Sidewinder"
    case aldousBroder = "AldousBroder"
    case wilsons = "Wilsons"
    case huntAndKill = "HuntAndKill"
    case recursiveBacktracker = "RecursiveBacktracker"
}
