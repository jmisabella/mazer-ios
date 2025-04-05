import Foundation

// Codable to make it serializable
// CaseIterable to allow iterating through lists of these
// Identifiable to make them uniquely identifiable, as required by ForEach
enum MazeAlgorithm: String, Codable, CaseIterable, Identifiable {
    case binaryTree = "BinaryTree"
    case sidewinder = "Sidewinder"
    case aldousBroder = "AldousBroder"
    case wilsons = "Wilsons"
    case huntAndKill = "HuntAndKill"
    case recursiveBacktracker = "RecursiveBacktracker"
    
    var id: String { rawValue }
}
