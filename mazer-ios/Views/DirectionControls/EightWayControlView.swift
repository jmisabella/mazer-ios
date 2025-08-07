//
//  EightWayControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/19/25.
//

import SwiftUI

struct EightWayControlView: View {
    let moveAction: (String) -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                directionButton(systemImage: "arrow.up.left", action: "UpperLeft")
                directionButton(systemImage: "arrow.up", action: "Up")
                directionButton(systemImage: "arrow.up.right", action: "UpperRight")
            }

            HStack(spacing: 16) {
                directionButton(systemImage: "arrow.left", action: "Left")
                Spacer().frame(width: 44)
                directionButton(systemImage: "arrow.right", action: "Right")
            }

            HStack(spacing: 16) {
                directionButton(systemImage: "arrow.down.left", action: "LowerLeft")
                directionButton(systemImage: "arrow.down", action: "Down")
                directionButton(systemImage: "arrow.down.right", action: "LowerRight")
            }
        }
        .padding(16)
        .background(
            Rectangle()
                .fill(CellColors.offWhite.opacity(0.4))
                .cornerRadius(16)
        )
        .shadow(radius: 4)
    }

    private func directionButton(systemImage: String, action dir: String) -> some View {
        Button {
            moveAction(dir)
        } label: {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.gray))
                .foregroundColor(.white)
        }
        .accessibilityLabel("Move \(dir)")
    }
}
