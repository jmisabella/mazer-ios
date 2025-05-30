//
//  SigmaDirectionControlViewi.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/25/25.
//

import SwiftUI

struct SigmaDirectionControlView: View {
    let moveAction: (String) -> Void

    var body: some View {
        HStack(spacing: 16) {
            // ←
            directionButton(systemImage: "arrow.left", action: "Left")
            
            // ╭ UL │ LL ╮
            VStack(spacing: 12) {
                directionButton(systemImage: "arrow.up.left",   action: "UpperLeft")
                directionButton(systemImage: "arrow.down.left", action: "LowerLeft")
            }

            // ↑ ↓
            VStack(spacing: 12) {
                directionButton(systemImage: "arrow.up",   action: "Up")
                directionButton(systemImage: "arrow.down", action: "Down")
            }

            // ╭ UR │ LR ╮
            VStack(spacing: 12) {
                directionButton(systemImage: "arrow.up.right",   action: "UpperRight")
                directionButton(systemImage: "arrow.down.right", action: "LowerRight")
            }
            
            // →
            directionButton(systemImage: "arrow.right", action: "Right")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(16)
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

struct SigmaDirectionControlView_Previews: PreviewProvider {
    static var previews: some View {
        SigmaDirectionControlView { dir in
            print("Moved \(dir)")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
