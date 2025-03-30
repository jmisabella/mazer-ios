import Foundation

// Codable to make it serializable
// CaseIterable to allow iterating through lists of these
// Identifiable to make them uniquely identifiable, as required by ForEach
enum MazeType: String, Codable, CaseIterable, Identifiable {
    case orthogonal = "Orthogonal"
    case sigma = "Sigma"
    case delta = "Delta"
    case polar = "Polar"
    
    var id: String { rawValue }
}
