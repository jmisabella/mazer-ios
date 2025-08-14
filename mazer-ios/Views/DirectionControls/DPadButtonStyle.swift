//
//  DPadButtonStyle.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/20/25.
//

import SwiftUI

struct DPadButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    init(colorScheme: ColorScheme) {
        self.backgroundColor = colorScheme == .dark ? "#2A2A2A".asColor : Color.gray
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 44, height: 44)
            .background(Circle().fill(backgroundColor))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
    
    static func directionButton(direction: MazeDirection, moveAction: @escaping (String) -> Void, colorScheme: ColorScheme) -> some View {
        Button {
            moveAction(direction.action)
        } label: {
            Image(systemName: direction.systemImage)
                .font(.title2)
                .foregroundColor(.white)
                .rotationEffect(direction.rotation)
        }
        .buttonStyle(DPadButtonStyle(colorScheme: colorScheme))
        .accessibilityLabel("Move \(direction.action)")
    }
}

