//
//  DirectionPadView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/20/25.
//

import SwiftUI

struct DirectionPadView<Dir: Hashable>: View {
  /// 2D array of directions, one sub‑array per row
  let layout: [[Dir]]
  /// Mapping each `Dir` to its systemImage name
  let iconName: (Dir) -> String
  /// Callback when one of them is tapped
  let action: (Dir) -> Void

  var body: some View {
    VStack(spacing: 4 ) {
      ForEach(layout, id: \.self) { row in
        HStack(spacing: 4) {
          ForEach(row, id: \.self) { dir in
            Button {
              action(dir)
            } label: {
              Image(systemName: iconName(dir))
                .symbolRenderingMode(.hierarchical)  // softer multi‑layer look
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            }
            .buttonStyle(DPadButtonStyle())
          }
        }
      }
    }
  }
}

