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
    @State private var selectedPalette: HeatMapPalette = allPalettes.randomElement()!
    @State private var mazeID = UUID()  // New state to track the current maze, specifically used to reset solution between mazes)
    let mazeCells: [MazeCell]
    let mazeType: MazeType  // "Orthogonal", "Sigma", etc.
    let regenerateMaze: () -> Void
    // handle move actions (buttons and later swipe gestures)
    let moveAction: (String) -> Void
    
    func computeCellSize() -> CGFloat {
        let columns = (mazeCells.map { $0.x }.max() ?? 0) + 1
        return UIScreen.main.bounds.width / CGFloat(columns) * 1.35
    }
    
    @ViewBuilder
    private var directionControlView: some View {
        switch mazeType {
        case .orthogonal:
            OrthogonalDirectionControlView(moveAction: moveAction)
                .id(mazeID) // Force view recreation when mazeID changes
                .padding(.top, 3)
        case .sigma:
            Text("Sigma rendering not implemented yet")
        case .delta:
            DeltaDirectionControlView(moveAction: moveAction)
                .id(mazeID)
                .padding(.top, 3)
        case .polar:
            Text("Polar rendering not implemented yet")
        }
    }

    
    // A computed property to build the maze content based on mazeType.
    @ViewBuilder
    var mazeContent: some View {
        switch mazeType {
        case .orthogonal:
            OrthogonalMazeView(
                selectedPalette: $selectedPalette,
                cells: mazeCells,
                showSolution: showSolution,
                showHeatMap: showHeatMap
            )
            .id(mazeID)
        case .sigma:
            Text("Sigma rendering not implemented yet")
        case .delta:
            let cellSize = computeCellSize()  // Compute as shown above.
                let maxDistance = mazeCells.map { $0.distance }.max() ?? 1
                DeltaMazeView(
                    cells: mazeCells,
                    cellSize: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    selectedPalette: selectedPalette, // pass wrapped value
                    maxDistance: maxDistance
                )
                .id(mazeID)
//            Text("Delta rendering not implemented yet")
        case .polar:
            Text("Polar rendering not implemented yet")
        }
    }
    
    // Compute cellSize based on the maze's grid.
    // Assumes mazeCells contains at least one cell.
    private func cellSize() -> CGFloat {
        let maxColumn = (mazeCells.map { $0.x }.max() ?? 0) + 1
        return UIScreen.main.bounds.width / CGFloat(maxColumn)
    }
    
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
                    //                    selectedPalette = allPalettes.randomElement()!
                    selectedPalette = randomPaletteExcluding(current: selectedPalette, from: allPalettes)
                    mazeID = UUID()   // Generate a new ID when regenerating the maze
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
                    //                    selectedPalette = allPalettes.randomElement()!
                    selectedPalette = randomPaletteExcluding(current: selectedPalette, from: allPalettes)
                }) {
                    Image(systemName: showHeatMap ? "flame.fill" : "flame")
                        .font(.title2)
                        .foregroundColor(showHeatMap ? .orange : .gray)
                }
                .accessibilityLabel("Toggle heat map")
            }
            .padding(.top)
            
            
            // The maze container:
            if mazeType == .orthogonal || mazeType == .delta {
                ZStack {
                    mazeContent
                }
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            if mazeType == .orthogonal {
                                // Existing orthogonal gesture logic:
                                let horizontalAmount = value.translation.width
                                let verticalAmount = value.translation.height
                                let cellDimension = cellSize() // your function that computes cell size
                                if abs(horizontalAmount) > abs(verticalAmount) {
                                    let movesCount = max(1, Int(round(abs(horizontalAmount) / cellDimension)))
                                    let direction = horizontalAmount < 0 ? "West" : "East"
                                    for i in 0..<movesCount {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                            moveAction(direction)
                                        }
                                    }
                                } else {
                                    let movesCount = max(1, Int(round(abs(verticalAmount) / cellDimension)))
                                    let direction = verticalAmount < 0 ? "North" : "South"
                                    for i in 0..<movesCount {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                            moveAction(direction)
                                        }
                                    }
                                }
                            } else if mazeType == .delta {
                                // Delta-specific gesture logic using angle sectors:
                                let tx = value.translation.width
                                let ty = value.translation.height
                                // If there's no movement, do nothing.
                                if tx == 0 && ty == 0 { return }
                                
                                // Compute the angle of the drag (in radians).
                                let angle = atan2(ty, tx)
                                // Shift the angle by π/6 (30°) so that boundaries align with our sectors.
                                let shiftedAngle = angle + (.pi/6)
                                // Normalize to [0, 2π).
                                var normalizedAngle = shiftedAngle
                                if normalizedAngle < 0 {
                                    normalizedAngle += 2 * .pi
                                }
                                // Divide the circle into 6 equal sectors (each π/3 radians wide).
                                let sectorIndex = Int(floor(normalizedAngle / (.pi/3)))
                                let directions = ["UpperRight", "Up", "UpperLeft", "LowerLeft", "Down", "LowerRight"]
                                let chosenDirection = directions[sectorIndex]
                                
                                // Determine how many moves to issue based on the magnitude of the translation.
                                let translationMagnitude = sqrt(tx * tx + ty * ty)
                                let cellDimension = cellSize()  // same cellSize function from above
                                let movesCount = max(1, Int(round(translationMagnitude / cellDimension)))
                                for i in 0..<movesCount {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                        moveAction(chosenDirection)
                                    }
                                }
                            }
                        }
                )
//            if mazeType == .orthogonal {
//                // For orthogonal mazes, wrap the maze content in a ZStack with an attached drag gesture.
//                ZStack {
//                    mazeContent
//                }
//                .gesture(
//                    DragGesture(minimumDistance: 10)
//                        .onEnded { value in
//                            let horizontalAmount = value.translation.width
//                            let verticalAmount = value.translation.height
//                            
//                            // Calculate the cellSize from the maze grid.
//                            let cellDimension = cellSize()
//                            
//                            // Depending on the dominant gesture axis, determine the number of moves.
//                            if abs(horizontalAmount) > abs(verticalAmount) {
//                                let movesCount = max(1, Int(round(abs(horizontalAmount) / cellDimension)))
//                                let direction = horizontalAmount < 0 ? "West" : "East"
//                                for i in 0..<movesCount {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
//                                        moveAction(direction)
//                                    }
//                                }
//                            } else {
//                                let movesCount = max(1, Int(round(abs(verticalAmount) / cellDimension)))
//                                let direction = verticalAmount < 0 ? "North" : "South"
//                                for i in 0..<movesCount {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
//                                        moveAction(direction)
//                                    }
//                                }
//                            }
//                        }
//                )
            } else {
                // For other maze types, no gesture is attached.
                ZStack {
                    mazeContent
                }
            }
            
            directionControlView
            
        }
        
    }
    
    
    
    func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
        guard showHeatMap, maxDistance > 0 else {
            return .gray  // fallback color when heat map is off
        }
        
        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    }
    
    func randomPaletteExcluding(current: HeatMapPalette, from allPalettes: [HeatMapPalette]) -> HeatMapPalette {
        let availablePalettes = allPalettes.filter { $0 != current }
        // If there’s at least one palette that isn’t the current, pick one at random.
        // Otherwise, fallback to returning the current palette.
        return availablePalettes.randomElement() ?? current
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
            },
            moveAction: { direction in
                // For preview purposes, simply print the direction.
                print("Move action triggered: \(direction)")
            }
        )
    }
}
