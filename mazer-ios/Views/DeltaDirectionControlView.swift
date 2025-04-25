//
//  DeltaDirectionControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI

struct DeltaDirectionControlView: View {
    /// Closure for handling move actions.
    let moveAction: (String) -> Void
    
    var body: some View {
        DirectionPadView(
          layout: [
            [MazeDirection.left, MazeDirection.upperLeft, MazeDirection.up, MazeDirection.upperRight, MazeDirection.right],
            [MazeDirection.lowerLeft, MazeDirection.down, MazeDirection.lowerRight]
          ],
          iconName: { $0.systemImage },
          action: { moveAction($0.rawValue.capitalized) }
        )
      }
    
    // MARK: - Helper
    
    private func directionButton(for direction: String,
                                 systemImage: String,
                                 label: String) -> some View {
        Button(action: {
            moveAction(direction)
        }) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 1)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.blue)
                )
        }
        .accessibilityLabel(label)
    }
}
