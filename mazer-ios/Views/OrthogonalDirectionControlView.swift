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
            DirectionPadView(
              layout: [
                [MazeDirection.left, MazeDirection.up, MazeDirection.right],
                [MazeDirection.down]
              ],
              iconName: { $0.systemImage },
              action: { moveAction($0.rawValue.capitalized) }
            )
        .padding(1) // Reduced overall outer padding.
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

