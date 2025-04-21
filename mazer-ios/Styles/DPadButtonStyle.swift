//
//  DPadButtonStyle.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/20/25.
//

import SwiftUI

struct DPadButtonStyle: ButtonStyle {
    /// Size of each tappable button
    var size: CGFloat = 36
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                // subtle iOS material background
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .fill(Color(.secondarySystemFill))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
