//
//  MazeGenerationAnimationView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/6/25.
//

import SwiftUI
import AudioToolbox

struct MazeGenerationAnimationView: View {
    let generationSteps: [[MazeCell]]  // Array of maze generation steps
    let mazeType: MazeType             // Type of maze for rendering
    let cellSize: CellSize
    @Binding var isAnimatingGeneration: Bool  // Controls animation visibility
    @Binding var mazeGenerated: Bool          // Triggers MazeRenderView
    @Binding var showSolution: Bool           // Toggles solution path
    @Binding var showHeatMap: Bool            // Toggles heat map
    @Binding var showControls: Bool           // Toggles navigation controls
    @Binding var selectedPalette: HeatMapPalette // Heat map palette
    @Binding var defaultBackground: Color     // Default background color
    @Binding var mazeID: UUID                 // Maze ID for refresh
    let currentGrid: OpaquePointer?
    let regenerateMaze: () -> Void            // Closure to regenerate maze
    let cleanupMazeData: () -> Void           // Closure to clean up memory
    let cellSizes: (square: CGFloat, octagon: CGFloat)
    let optionalColor: Color?

    @State private var currentStepIndex = 0   // Tracks current animation step

    // Function to toggle heat map and update palette
    private func toggleHeatMap() {
        showHeatMap.toggle()
        if showHeatMap {
            selectedPalette = randomPaletteExcluding(current: selectedPalette, from: allPalettes)
            defaultBackground = randomDefaultExcluding(current: defaultBackground, from: CellColors.defaultBackgroundColors)
        }
    }
    
    private var horizontalAdjustment: CGFloat {
        navigationMenuHorizontalAdjustment(mazeType: mazeType, cellSize: cellSize)
    }
    private var verticalAdjustment: CGFloat {
        navigationMenuVerticalAdjustment(mazeType: mazeType, cellSize: cellSize)
    }

    // Helper to select random palette excluding current
    private func randomPaletteExcluding(current: HeatMapPalette, from allPalettes: [HeatMapPalette]) -> HeatMapPalette {
        let availablePalettes = allPalettes.filter { $0 != current }
        return availablePalettes.randomElement() ?? current
    }

    // Helper to select random default background excluding current
    private func randomDefaultExcluding(current: Color, from all: [Color]) -> Color {
        let others = all.filter { $0 != current }
        return others.randomElement() ?? current
    }
    
    @ViewBuilder
    func makeMazeView(currentCells: [MazeCell]) -> some View {
        switch mazeType {
        case .orthogonal:
            OrthogonalMazeView(
                selectedPalette: .constant(wetAsphaltPalette),
                cells: currentCells,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
            )
            .id(currentStepIndex)
            
        case .delta:
            DeltaMazeView(
                cells: currentCells,
                cellSize: computeCellSize(mazeCells: generationSteps[0], mazeType: mazeType, cellSize: cellSize),
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                selectedPalette: selectedPalette, // Adjust to $selectedPalette if Binding is required
                maxDistance: currentCells.map(\.distance).max() ?? 1,
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
            )
            .id(currentStepIndex)
            
        case .sigma:
            SigmaMazeView(
                selectedPalette: .constant(wetAsphaltPalette),
                cells: currentCells,
                cellSize: computeCellSize(mazeCells: generationSteps[0], mazeType: mazeType, cellSize: cellSize),
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
            )
            .id(currentStepIndex)
            
        case .upsilon:
            UpsilonMazeView(
                cells: currentCells,
                octagonSize: cellSizes.octagon,
                squareSize: cellSizes.square,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                selectedPalette: selectedPalette, // Adjust to $selectedPalette if Binding is required
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
            )
            .id(currentStepIndex)
            
        case .rhombic:
            GeometryReader { geo in
                let maxX = currentCells.map { $0.x }.max() ?? 0
                let maxY = currentCells.map { $0.y }.max() ?? 0
                let sqrt2 = CGFloat(2).squareRoot()
                let cellSize = computeCellSize(mazeCells: generationSteps[0], mazeType: mazeType, cellSize: self.cellSize)
                let diagonal = cellSize * sqrt2
                let gridWidth = diagonal * (CGFloat(maxX) + 1)
                let gridHeight = diagonal * (CGFloat(maxY) + 1)
                let offsetX = (geo.size.width - gridWidth) / 2
                let offsetY = (geo.size.height - gridHeight) / 2
                
                RhombicMazeView(
                    selectedPalette: $selectedPalette,
                    cells: currentCells,
                    cellSize: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    defaultBackgroundColor: defaultBackground,
                    optionalColor: optionalColor
                )
                .id(currentStepIndex)
                .offset(x: offsetX, y: offsetY)
                .padding(.top, 7)
            }
            
        default:
            Text("Unsupported maze type")
        }
    }

    var body: some View {
        VStack {
            // Navigation bar matching MazeRenderView, with fully functional buttons
            HStack(spacing: 16) {
                Button(action: {
                    cleanupMazeData()
                }) {
                    Image(systemName: "arrow.uturn.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Back to maze settings")

                Button(action: {
                    defaultBackground = CellColors.defaultBackgroundColors.randomElement()!
//                    // Clear the generation steps from memory
//                    if let gridPtr = currentGrid {
//                        mazer_clear_generation_steps(gridPtr)
//                    }
                    mazeID = UUID()
                    regenerateMaze()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .disabled(true)
                .accessibilityLabel("Generate new maze")

                Button(action: {
                    showSolution.toggle()
                }) {
                    Image(systemName: showSolution ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(showSolution ? .green : .gray)
                }
                .accessibilityLabel("Toggle solution path")

                Button(action: toggleHeatMap) {
                    Image(systemName: showHeatMap ? "flame.fill" : "flame")
                        .font(.title2)
                        .foregroundColor(showHeatMap ? .orange : .gray)
                }
                .accessibilityLabel("Toggle heat map")

                Button {
                    withAnimation { showControls.toggle() }
                } label: {
                    Image(systemName: showControls ? "xmark.circle.fill" : "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .disabled(true)
                .accessibilityLabel("Toggle navigation controls")
            }
            .offset(x: horizontalAdjustment, y: verticalAdjustment)
//            .padding(.top)

            if currentStepIndex < generationSteps.count {
                ZStack {
                    let currentCells = generationSteps[currentStepIndex]
                    
                    makeMazeView(currentCells: currentCells)

                    // Cancel button in upper right
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                // Skip animation and go to MazeRenderView
                                isAnimatingGeneration = false
                                mazeGenerated = true
                                AudioServicesPlaySystemSound(1104)
                                // Change to a new random default background color
                                defaultBackground = CellColors.defaultBackgroundColors.filter { $0 != defaultBackground }.randomElement() ?? defaultBackground
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white.opacity(0.7))
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                                    .frame(width: 57, height: 57)
                            }
                            .accessibilityLabel("Cancel maze generation animation")
                            .padding(.trailing, 24)
                            .padding(.top, 16)
                        }
                        Spacer()
                    }
                }
                .onAppear {
                    for i in 0..<generationSteps.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                            currentStepIndex = i
                            if i == generationSteps.count - 1 {
                                isAnimatingGeneration = false
                                mazeGenerated = true
                                AudioServicesPlaySystemSound(1104)
                                // Change to a new random default background color
                                defaultBackground = CellColors.defaultBackgroundColors.filter { $0 != defaultBackground }.randomElement() ?? defaultBackground
                            
                            }
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}
