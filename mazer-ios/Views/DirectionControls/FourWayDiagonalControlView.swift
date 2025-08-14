//
//  FourWayDiagonalControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/28/25.
//

import SwiftUI

struct FourWayDiagonalControlView: View {
    let moveAction: (String) -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let alpha = colorScheme == .dark ? 0.6 : 0.75
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                DPadButtonStyle.directionButton(direction: .upperLeft, moveAction: moveAction, colorScheme: colorScheme)
                DPadButtonStyle.directionButton(direction: .upperRight, moveAction: moveAction, colorScheme: colorScheme)
            }
            HStack(spacing: 16) {
                DPadButtonStyle.directionButton(direction: .lowerLeft, moveAction: moveAction, colorScheme: colorScheme)
                DPadButtonStyle.directionButton(direction: .lowerRight, moveAction: moveAction, colorScheme: colorScheme)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(UIColor.systemBackground).opacity(alpha))
        )
    }
}
