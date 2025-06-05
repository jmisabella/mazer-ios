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
    case prims = "Prims"
    case kruskals = "Kruskals"
    case growingTree = "GrowingTree"
    case ellers = "Ellers"
    case recursiveDivision = "RecursiveDivision"
    
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
        case .prims:
            return "Prim’s algorithm starts with a random cell and grows the maze by adding passages to unvisited neighbors with the lowest random weights. It produces mazes with a uniform structure and moderate-length passages."
        case .kruskals:
            return "Kruskal’s algorithm treats the grid as a graph, randomly merging cells by removing walls to form a minimum spanning tree. It creates mazes with a uniform, tree-like structure and no bias in direction."
        case .growingTree:
            return "This algorithm maintains a list of active cells, choosing one to carve a passage to an unvisited neighbor, with behavior varying by selection strategy (e.g., random or newest). It can mimic other algorithms like Recursive Backtracker."
        case .ellers:
            return "Eller’s algorithm builds the maze row by row, randomly joining cells within each row and ensuring connectivity to the next row. It produces mazes with a row-wise structure and is memory-efficient for infinite mazes."
        case .recursiveDivision:
            return "This method starts with an open grid and recursively divides it into chambers by adding walls with random passages. It creates mazes with a hierarchical layout, featuring long walls and fewer dead ends."
        }
    }
}
