//
//  OrthogonalCellView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

struct OrthogonalCellView: View {
    let cell: MazeCell
    let size: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let isRevealedSolution: Bool
    let defaultBackgroundColor: Color

    var body: some View {
        // 1️⃣ compute your stroke width once
        let w = cellStrokeWidth(for: size, mazeType: .orthogonal)
        // 2️⃣ half so you can inset your path
        let half = w / 2

        ZStack {
          // background
            Rectangle()
                .fill(cellBackgroundColor(
                    for: cell,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    maxDistance: maxDistance,
                    selectedPalette: selectedPalette,
                    isRevealedSolution: isRevealedSolution,
                    defaultBackground: defaultBackgroundColor
                ))
                .frame(width: size, height: size)

          // walls
          Path { path in
            // inset all four corners by half
            let tl = CGPoint(x: half,       y: half)
            let tr = CGPoint(x: size - half, y: half)
            let br = CGPoint(x: size - half, y: size - half)
            let bl = CGPoint(x: half,       y: size - half)

            // draw in clockwise order, but only stroke the ones you need
            if !cell.linked.contains("Up") {
              path.move(to: tl)
              path.addLine(to: tr)
            }
            if !cell.linked.contains("Right") {
              path.move(to: tr)
              path.addLine(to: br)
            }
            if !cell.linked.contains("Down") {
              path.move(to: br)
              path.addLine(to: bl)
            }
            if !cell.linked.contains("Left") {
              path.move(to: bl)
              path.addLine(to: tl)
            }
          }
          .stroke(
            Color.black,
            style: StrokeStyle(
              lineWidth: w,
              lineCap: .square, // square or .round
              lineJoin: .round   // bevel or .round
            )
          )
          .frame(width: size, height: size)
          // no .clipped() here
        }
      }

}
