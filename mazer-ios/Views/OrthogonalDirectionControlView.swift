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
        HStack(spacing: 32) {
            // ←
            directionButton(systemImage: "arrow.left", action: "Left")
            
            // ↑ and ↓ stacked
            VStack(spacing: 8) {
                directionButton(systemImage: "arrow.up",   action: "Up")
                directionButton(systemImage: "arrow.down", action: "Down")
            }
            
            // →
            directionButton(systemImage: "arrow.right", action: "Right")
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

