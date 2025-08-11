//
//  FourWayControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/12/25.
//

import SwiftUI

struct FourWayControlView: View {
    let moveAction: (String) -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let alpha = colorScheme == .dark ? 0.6 : 0.75
        HStack(spacing: 2) {
            DPadButtonStyle.directionButton(direction: .left, moveAction: moveAction, colorScheme: colorScheme)
            VStack(spacing: 8) {
                DPadButtonStyle.directionButton(direction: .up, moveAction: moveAction, colorScheme: colorScheme)
                DPadButtonStyle.directionButton(direction: .down, moveAction: moveAction, colorScheme: colorScheme)
            }
            DPadButtonStyle.directionButton(direction: .right, moveAction: moveAction, colorScheme: colorScheme)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 64)
                .fill(Color(UIColor.systemBackground).opacity(alpha))
        )
    }
}
