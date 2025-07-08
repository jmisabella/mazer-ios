import Foundation

// Codable to make it serializable
// CaseIterable to allow iterating through lists of these
// Identifiable to make them uniquely identifiable, as required by ForEach
enum MazeType: String, Codable, CaseIterable, Identifiable {
    case delta = "Delta"
    case orthogonal = "Ortho"
    case rhombic = "Rhombic"
    case sigma = "Sigma"
    case upsilon = "Upsilon"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .delta:
            return "Triangular cells (normal and inverted) creating jagged, complex paths."
        case .orthogonal:
            return "Orthogonal mazes carve a classic square-grid layout with straight paths and right-angle turns."
        case .rhombic:
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
        case .rhombic:
            return "Rhombic"
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
        case "Rhombic": return .rhombic
        default: return nil
        }
    }
    
    /// Returns the list of available maze types, optionally filtering out rhombic for small screens.
    /// - Parameter isSmallScreen: If true, excludes rhombic maze type (e.g., for devices with screen height <= 667.0).
    /// - Returns: An array of available `MazeType` cases.
    static func availableMazeTypes(isSmallScreen: Bool) -> [MazeType] {
        if isSmallScreen {
            return allCases.filter { $0 != .rhombic }
        }
        return allCases
    }
    
}
