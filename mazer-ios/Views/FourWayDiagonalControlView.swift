//
//  FourWayDiagonalControlView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/28/25.
//

import SwiftUI

struct FourWayDiagonalControlView: View {
    let moveAction: (String) -> Void

    var body: some View {
        ZStack {
            // Upper Right
            directionButton(systemImage: "arrow.up.right", action: "UpperRight")
                .offset(x: 28, y: -28)
            
            // Lower Right
            directionButton(systemImage: "arrow.down.right", action: "LowerRight")
                .offset(x: 28, y: 28)
            
            // Lower Left
            directionButton(systemImage: "arrow.down.left", action: "LowerLeft")
                .offset(x: -28, y: 28)
            
            // Upper Left
            directionButton(systemImage: "arrow.up.left", action: "UpperLeft")
                .offset(x: -28, y: -28)
        }
        .frame(width: 120, height: 120)
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
