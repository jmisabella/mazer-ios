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
        VStack(spacing: 8) {
            // ┌───┐
            // │ ↑ │
            // └───┘
            HStack {
                Spacer()
                directionButton(systemImage: "arrow.up", action: "Up")
                Spacer()
            }

            // ┌───┬───┐
            // │ ← │ → │
            // └───┴───┘
            HStack(spacing: 32) {           // wider gap between Left & Right
                directionButton(systemImage: "arrow.left",  action: "Left")
                directionButton(systemImage: "arrow.right", action: "Right")
            }
            .padding(.vertical, 8)          // a bit of breathing room around the LR row

            // ┌───┐
            // │ ↓ │
            // └───┘
            HStack {
                Spacer()
                directionButton(systemImage: "arrow.down", action: "Down")
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(12)
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

