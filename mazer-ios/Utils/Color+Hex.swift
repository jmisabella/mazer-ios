//
//  Color+Extensions.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/4/25.
//

import SwiftUI


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                     .replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 1.0; g = 1.0; b = 1.0 // fallback to white
        }

        self.init(red: r, green: g, blue: b)
    }

//    static let solutionHighlight = Color(hex: "#CCFF00") // radioactive neon lime!
    static let solutionHighlight = Color(hex: "#04D9FF") // radiant neon blue!
    
    static let offWhite = Color(hex: "FFF5E6")
    
    static let orangeRed = Color(hex: "F66E6E")
    
    static let lightGrey = Color(hex: "333333")
    
    static let softOrange = Color(hex: "FFCCBC")
    
    static let lightSkyBlue = Color(hex: "ADD8E6")

}

extension String {
    var asColor: Color {
        let hex = self.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8) & 0xff) / 255
        let b = Double(int & 0xff) / 255
        return Color(red: r, green: g, blue: b)
    }
}
