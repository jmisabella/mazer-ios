//
//  DeltaDirectionControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/13/25.
//

import SwiftUI


struct DeltaDirectionControlView: View {
    /// Closure for handling move actions
    let moveAction: (String) -> Void
    /// Indicates whether the current active cell has a Normal orientation (true)
    /// or an Inverted orientation (false)
    let isNormal: Bool

    var body: some View {
        VStack(spacing: 1) {
            if isNormal {
                // For Normal cells: two directional buttons in the top row, one in the bottom.
                HStack(spacing: 4) {
                    Button(action: { moveAction("UpperLeft") }) {
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    .accessibilityLabel("Move Upper Left")
                    
                    Button(action: { moveAction("UpperRight") }) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    .accessibilityLabel("Move Upper Right")
                }
                
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
            } else {
                // For Inverted cells: one button in the top row, two in the bottom.
                HStack {
                    Spacer()
                    Button(action: { moveAction("Up") }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    .accessibilityLabel("Move Up")
                    Spacer()
                }
                
                HStack(spacing: 4) {
                    Button(action: { moveAction("LowerLeft") }) {
                        Image(systemName: "arrow.down.left")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    .accessibilityLabel("Move Lower Left")
                    
                    Button(action: { moveAction("LowerRight") }) {
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    .accessibilityLabel("Move Lower Right")
                }
            }
        }
        .padding(1)
        // Add a drag gesture so that the user can swipe in the Delta control area
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    if isNormal {
                        // For Normal cells:
                        // If the vertical movement is downward then interpret as "Down".
                        // Otherwise, if upward: if horizontal is negative, choose "UpperLeft", else "UpperRight".
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        if verticalAmount > 0 {
                            moveAction("Down")
                        } else {
                            if horizontalAmount < 0 {
                                moveAction("UpperLeft")
                            } else {
                                moveAction("UpperRight")
                            }
                        }
                    } else {
                        // For Inverted cells:
                        // If the vertical movement is upward then interpret as "Up".
                        // Otherwise, if downward: if horizontal is negative, choose "LowerLeft", else "LowerRight".
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        if verticalAmount < 0 {
                            moveAction("Up")
                        } else {
                            if horizontalAmount < 0 {
                                moveAction("LowerLeft")
                            } else {
                                moveAction("LowerRight")
                            }
                        }
                    }
                }
        )
    }
}

struct DeltaDirectionControlView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Normal Orientation")
            DeltaDirectionControlView(
                moveAction: { direction in
                    print("Delta Normal move: \(direction)")
                },
                isNormal: true
            )
            
            Divider()
            
            Text("Inverted Orientation")
            DeltaDirectionControlView(
                moveAction: { direction in
                    print("Delta Inverted move: \(direction)")
                },
                isNormal: false
            )
        }
        .padding()
    }
}
