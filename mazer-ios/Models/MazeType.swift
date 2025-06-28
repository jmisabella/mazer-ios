import Foundation

// Codable to make it serializable
// CaseIterable to allow iterating through lists of these
// Identifiable to make them uniquely identifiable, as required by ForEach
enum MazeType: String, Codable, CaseIterable, Identifiable {
    case delta = "Delta"
    case orthogonal = "Ortho"
    case rhombille = "Rhombic"
    case sigma = "Sigma"
    case upsilon = "Upsilon"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .delta:
            return "Triangular cells (normal and inverted) creating jagged, complex paths."
        case .orthogonal:
            return "Orthogonal mazes carve a classic square-grid layout with straight paths and right-angle turns."
        case .rhombille:
            return "Diamond cells forming a grid with slanted paths."
        case .sigma:
            return "Hexagonal cells forming a web of interconnected paths, promoting more intuitive navigation."
        case .upsilon:
            return "Alternating octagon and square cells add variety to pathfinding."
        }
    }
    
    var ffiName: String {
        switch self {
        case .delta:
            return "Delta"
        case .orthogonal:
            return "Orthogonal"
        case .rhombille:
            return "Rhombille"
        case .sigma:
            return "Sigma"
        case .upsilon:
            return "Upsilon"
        }
    }
    
    static func fromFFIName(_ name: String) -> MazeType? {
        switch name {
        case "Delta": return .delta
        case "Orthogonal": return .orthogonal
        case "Sigma": return .sigma
        case "Upsilon": return .upsilon
        case "Rhombille": return .rhombille
        default: return nil
        }
    }
    
}
