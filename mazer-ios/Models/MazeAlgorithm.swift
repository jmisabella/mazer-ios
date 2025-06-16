import Foundation

// Codable to make it serializable
// CaseIterable to allow iterating through lists of these
// Identifiable to make them uniquely identifiable, as required by ForEach
enum MazeAlgorithm: String, Codable, CaseIterable, Identifiable {
    case aldousBroder = "AldousBroder"
    case binaryTree = "BinaryTree"
    case ellers = "Ellers"
    case growingTreeNewest = "GrowingTreeNewest"
    case growingTreeRandom = "GrowingTreeRandom"
    case huntAndKill = "HuntAndKill"
    case kruskals = "Kruskals"
    case prims = "Prims"
    case recursiveBacktracker = "RecursiveBacktracker"
    case recursiveDivision = "RecursiveDivision"
    case sidewinder = "Sidewinder"
    case wilsons = "Wilsons"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .aldousBroder:
            return "This algorithm performs a random walk over the grid, carving a passage whenever it encounters an unvisited cell. It produces an unbiased maze, though it can be inefficient because it may visit cells many times."
        case .binaryTree:
            return "This method iterates through each cell in a grid, carving passages either north or east (or in another fixed pair of directions). The result is a maze with a predictable bias and long, straight corridors."
        case .ellers:
            return "Eller’s algorithm builds the maze row by row, randomly joining cells within each row and ensuring connectivity to the next row. It produces mazes with a row-wise structure and is memory-efficient for infinite mazes."
        case .growingTreeNewest:
            return "This algorithm maintains a list of active cells, always choosing the newest one to carve a passage to an unvisited neighbor. It can mimic other algorithms like Recursive Backtracker."
        case .growingTreeRandom:
            return "This algorithm maintains a list of active cells, choosing one randomly to carve a passage to an unvisited neighbor. It can mimic other algorithms like Recursive Backtracker."
        case .huntAndKill:
            return "Combining random walks with systematic scanning, this method randomly carves a passage until it reaches a dead end, then 'hunts' for an unvisited cell adjacent to the currently carved maze. This process creates mazes with long corridors and noticeable dead ends, balancing randomness with structure."
        case .kruskals:
            return "Kruskal’s algorithm treats the grid as a graph, randomly merging cells by removing walls to form a minimum spanning tree. It creates mazes with a uniform, tree-like structure and no bias in direction."
        case .prims:
            return "Prim’s algorithm starts with a random cell and grows the maze by adding passages to unvisited neighbors with the lowest random weights. It produces mazes with a uniform structure and moderate-length passages."
        case .recursiveBacktracker:
            return "Essentially a depth-first search, this algorithm recursively explores neighbors and backtracks upon reaching dead ends. It’s fast and generates mazes with long, twisting passages and fewer short loops."
        case .recursiveDivision:
            return "This method starts with an open grid and recursively divides it into chambers by adding walls with random passages. It creates mazes with a hierarchical layout, featuring long walls and fewer dead ends."
        case .sidewinder:
            return "Processed row-by-row, this algorithm carves eastward passages with occasional upward connections. It creates mazes with a strong horizontal bias and randomly placed vertical links."
        case .wilsons:
            return "Wilson’s algorithm uses loop-erased random walks, starting from a random cell and extending a path until it connects with the growing maze. It produces uniformly random mazes and avoids the inefficiencies of Aldous-Broder."
        }
    }
    
    var displayName: String {
        switch self {
        case .aldousBroder:
            return "Aldous Broder"
        case .binaryTree:
            return "Binary Tree"
        case .ellers:
            return "Eller’s"
        case .growingTreeNewest:
            return "Growing Tree (Newest Selection)"
        case .growingTreeRandom:
            return "Growing Tree (Random Selection)"
        case .huntAndKill:
            return "Hunt and Kill"
        case .kruskals:
            return "Kruskal’s"
        case .prims:
            return "Prim's"
        case .recursiveBacktracker:
            return "Recursive Backtracker"
        case .recursiveDivision:
            return "Recursive Division"
        case .sidewinder:
            return "Sidewinder"
        case .wilsons:
            return "Wilson's"
        }
    }
}
