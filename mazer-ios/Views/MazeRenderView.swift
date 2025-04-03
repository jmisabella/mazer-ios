//
//  MazeRenderView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

struct MazeRenderView: View {
    let mazeCells: [MazeCell]
    let mazeType: MazeType  // "Orthogonal", "Sigma", etc.
    
    @State private var showSolution: Bool = false
    @State private var showHeatMap: Bool = false
    
    var body: some View {
        VStack {
            // 🔲 Toggle bar
            HStack(spacing: 16) {
                // Solution toggle
                Button(action: {
                    showSolution.toggle()
                }) {
                    Image(systemName: showSolution ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(showSolution ? .green : .gray)
                }
                .accessibilityLabel("Toggle solution path")

                // Heat map toggle (acts like a radio switch)
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
            
            // 🧱 Maze grid rendering
            ScrollView {
//                LazyVGrid(columns: [...]) {
//                    ForEach(mazeCells, id: \.self) { cell in
//                        Text("(\(cell.x),\(cell.y))") // Placeholder
//                            .padding(4)
//                            .background(determineCellColor(for: cell))
//                            .cornerRadius(4)
//                    }
//                }
            }
        }
        
    }
}

struct MazeRenderView_Previews: PreviewProvider {
    static var previews: some View {
        MazeRenderView(mazeCells: [], mazeType: .orthogonal)
    }
}
