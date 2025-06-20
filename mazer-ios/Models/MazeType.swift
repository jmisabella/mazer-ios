import Foundation

// Codable to make it serializable
// CaseIterable to allow iterating through lists of these
// Identifiable to make them uniquely identifiable, as required by ForEach
enum MazeType: String, Codable, CaseIterable, Identifiable {
    case delta = "Delta"
    case orthogonal = "Orthogonal"
    case sigma = "Sigma"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .delta:
            return "Triangular cells (normal and inverted) creating jagged, complex paths."
        case .orthogonal:
            return "Classic square grid with straight paths and right-angle turns."
        case .sigma:
            return "Hexagonal web with multiple directions, making routes tricky."

        }
    }
}
