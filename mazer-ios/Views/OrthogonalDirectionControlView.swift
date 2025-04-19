//
//  OrthogonalDirectionControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/12/25.
//

import SwiftUI

struct OrthogonalDirectionControlView: View {
    let moveAction: (String) -> Void
    
    var body: some View {
        VStack(spacing: 1) { // Reduced vertical spacing between rows.
            // Up button row: centered horizontally.
            HStack {
                Spacer()
                Button(action: { moveAction("Up") }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 1)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                .accessibilityLabel("Move Up")
                Spacer()
            }
            
            // Middle row with left and right buttons.
            HStack(spacing: 4) { // Use a bit of horizontal spacing.
                Button(action: { moveAction("Left") }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 1)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                .accessibilityLabel("Move Left")
                
                Button(action: { moveAction("Right") }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 1)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                .accessibilityLabel("Move Right")
            }
            
            // Down button row: centered horizontally.
            HStack {
                Spacer()
                Button(action: { moveAction("Down") }) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                .accessibilityLabel("Move Down")
                Spacer()
            }
        }
        .padding(1) // Reduced overall outer padding.
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    // Check whether the swipe was primarily horizontal or vertical.
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < 0 {
                            moveAction("Left")
                        } else {
                            moveAction("Right")
                        }
                    } else {
                        if verticalAmount < 0 {
                            moveAction("Up")
                        } else {
                            moveAction("Down")
                        }
                    }
                }
        )
    }
}

struct OrthogonalDirectionControlView_Previews: PreviewProvider {
    static var previews: some View {
        OrthogonalDirectionControlView(
            moveAction: { direction in
                // For preview purposes, simply print the direction.
                print("Move action triggered: \(direction)")
            }
        )
    }
}

