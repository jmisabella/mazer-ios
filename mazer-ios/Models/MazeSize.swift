//
//  MazeSize.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

enum MazeSize: Int, CaseIterable, Identifiable {
    case small = 8, medium = 9, large = 15
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
}
