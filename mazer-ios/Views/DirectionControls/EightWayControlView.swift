//
//  EightWayControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/19/25.
//

import SwiftUI

struct EightWayControlView: View {
    let moveAction: (String) -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let verticalShift: CGFloat = 7
        let horizontalShift: CGFloat = 15
        let alpha = colorScheme == .dark ? 0.6 : 0.75

        VStack(spacing: 8) {
            HStack(spacing: 16) {
                DPadButtonStyle.directionButton(direction: .upperLeft, moveAction: moveAction, colorScheme: colorScheme)
                    .offset(x: horizontalShift, y: verticalShift)
                DPadButtonStyle.directionButton(direction: .up, moveAction: moveAction, colorScheme: colorScheme)
                DPadButtonStyle.directionButton(direction: .upperRight, moveAction: moveAction, colorScheme: colorScheme)
                    .offset(x: -horizontalShift, y: verticalShift)
            }
            HStack(spacing: 16) {
                DPadButtonStyle.directionButton(direction: .left, moveAction: moveAction, colorScheme: colorScheme)
                Spacer().frame(width: 44)
                DPadButtonStyle.directionButton(direction: .right, moveAction: moveAction, colorScheme: colorScheme)
            }
            HStack(spacing: 16) {
                DPadButtonStyle.directionButton(direction: .lowerLeft, moveAction: moveAction, colorScheme: colorScheme)
                    .offset(x: horizontalShift, y: -verticalShift)
                DPadButtonStyle.directionButton(direction: .down, moveAction: moveAction, colorScheme: colorScheme)
                DPadButtonStyle.directionButton(direction: .lowerRight, moveAction: moveAction, colorScheme: colorScheme)
                    .offset(x: -horizontalShift, y: -verticalShift)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 64)
                .fill(Color(UIColor.systemBackground).opacity(alpha))
        )
    }
}
