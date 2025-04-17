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
        VStack(spacing: 4) {
            // Top row: UpperLeft, Up, UpperRight
            HStack(spacing: 4) {
                directionButton(for: "UpperLeft",  systemImage: "arrow.up.left",  label: "Move Upper Left")
                directionButton(for: "Up",         systemImage: "arrow.up",       label: "Move Up")
                directionButton(for: "UpperRight", systemImage: "arrow.up.right", label: "Move Upper Right")
            }
            // Middle row: Left, Right
            HStack(spacing: 4) {
                directionButton(for: "Left",  systemImage: "arrow.left",  label: "Move Left")
                directionButton(for: "Right", systemImage: "arrow.right", label: "Move Right")
            }
            // Bottom row: LowerLeft, Down, LowerRight
            HStack(spacing: 4) {
                directionButton(for: "LowerLeft",  systemImage: "arrow.down.left",  label: "Move Lower Left")
                directionButton(for: "Down",       systemImage: "arrow.down",        label: "Move Down")
                directionButton(for: "LowerRight", systemImage: "arrow.down.right", label: "Move Lower Right")
            }
        }
        .padding(1)
        // Keep your existing gesture if you still want swipes:
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount   = value.translation.height
                    if abs(verticalAmount) > abs(horizontalAmount) {
                        // Vertical swipe
                        moveAction(verticalAmount < 0 ? "Up" : "Down")
                    } else {
                        // Horizontal swipe: pick a diagonal as a fallback
                        moveAction(horizontalAmount < 0 ? "UpperLeft" : "UpperRight")
                    }
                }
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
                        .fill(Color.blue.opacity(0.2))
                )
        }
        .accessibilityLabel(label)
    }
}
