//
//  MazeRenderView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

struct MazeRenderView: View {
    @Binding var mazeGenerated: Bool
    @Binding var showSolution: Bool
    @Binding var showHeatMap: Bool
    let mazeCells: [MazeCell]
    let mazeType: MazeType  // "Orthogonal", "Sigma", etc.
    let regenerateMaze: () -> Void
    
    
    
    @State private var selectedPalette: HeatMapPalette = allPalettes.randomElement()!
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                // Back button
                Button(action: {
                    mazeGenerated = false  // Goes back to MazeRequestView
                }) {
                    Image(systemName: "arrow.uturn.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Back to maze settings")

                // Regenerate button
                Button(action: {
                    regenerateMaze()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                .accessibilityLabel("Generate new maze")

                // Solution toggle
                Button(action: {
                    showSolution.toggle()
                }) {
                    Image(systemName: showSolution ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(showSolution ? .green : .gray)
                }
                .accessibilityLabel("Toggle solution path")

                // Heat map toggle
                Button(action: {
                    showHeatMap.toggle()
                }) {
                    Image(systemName: showHeatMap ? "flame.fill" : "flame")
                        .font(.title2)
                        .foregroundColor(showHeatMap ? .orange : .gray)
                }
                .accessibilityLabel("Toggle heat map")
            }
            .padding(.top)

            
            // 👇 Maze content based on mazeType
            switch mazeType {
            case .orthogonal:
                OrthogonalMazeView(
                    selectedPalette: $selectedPalette,
                    cells: mazeCells,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap
                )
            case .sigma:
                Text("Sigma rendering not implemented yet")
            case .delta:
                Text("Delta rendering not implemented yet")
            case .polar:
                Text("Polar rendering not implemented yet")
            }
        }
        
    }
    
    func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
        guard showHeatMap, maxDistance > 0 else {
            return .gray  // fallback color when heat map is off
        }

        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    }

}

struct MazeRenderView_Previews: PreviewProvider {
    static var previews: some View {
        MazeRenderView(
            mazeGenerated: .constant(false),
            showSolution: .constant(false),
            showHeatMap: .constant(false),
            mazeCells: [],
            mazeType: .orthogonal,
            regenerateMaze: {
                print("Maze Render Preview Triggered")
            }
        )
    }
}
