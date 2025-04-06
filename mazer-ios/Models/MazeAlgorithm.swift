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
    
    var description: String {
        switch self {
        case .binaryTree:
            return "This method iterates through each cell in a grid, carving passages either north or east (or in another fixed pair of directions). The result is a maze with a predictable bias and long, straight corridors."
        case .sidewinder:
            return "Processed row-by-row, this algorithm carves eastward passages with occasional upward connections. It creates mazes with a strong horizontal bias and randomly placed vertical links."
        case .aldousBroder:
            return "This algorithm performs a random walk over the grid, carving a passage whenever it encounters an unvisited cell. It produces an unbiased maze, though it can be inefficient because it may visit cells many times."
        case .wilsons:
            return "Wilson’s algorithm uses loop-erased random walks, starting from a random cell and extending a path until it connects with the growing maze. It produces uniformly random mazes and avoids the inefficiencies of Aldous-Broder."
        case .huntAndKill:
            return "Combining random walks with systematic scanning, this method randomly carves a passage until it reaches a dead end, then 'hunts' for an unvisited cell adjacent to the currently carved maze. This process creates mazes with long corridors and noticeable dead ends, balancing randomness with structure."
        case .recursiveBacktracker:
            return "Essentially a depth-first search, this algorithm recursively explores neighbors and backtracks upon reaching dead ends. It’s fast and generates mazes with long, twisting passages and fewer short loops."
        }
    }
}
