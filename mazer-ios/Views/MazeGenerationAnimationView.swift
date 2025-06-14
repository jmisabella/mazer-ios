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

    @State private var currentStepIndex = 0   // Tracks current animation step

//    func computeCellSize() -> CGFloat {
//        let cols = (generationSteps[0].map { $0.x }.max() ?? 0) + 1
//        switch mazeType {
//        case .orthogonal:
//            return UIScreen.main.bounds.width / CGFloat(cols)
//        case .delta:
////            let padding: CGFloat = 40
////            let available = UIScreen.main.bounds.width - padding * 2
////            return available * 2 / (CGFloat(cols) + 1)
//            return computeDeltaCellSize()
//        case .sigma:
//            let units = 1.5 * CGFloat(cols - 1) + 1
//            return UIScreen.main.bounds.width / units
//        default:
//            return UIScreen.main.bounds.width / CGFloat(cols)
//        }
//    }
    
    // Compute cell size based on maze type, consistent with MazeRenderView
    func computeCellSize() -> CGFloat {
        let cols = (generationSteps[0].map { $0.x }.max() ?? 0) + 1
        switch mazeType {
        case .orthogonal:
            return UIScreen.main.bounds.width / CGFloat(cols)
        case .delta:
            return computeDeltaCellSize(cols: cols)
        case .sigma:
            let units = 1.5 * CGFloat(cols - 1) + 1
            return UIScreen.main.bounds.width / units
        default:
            return UIScreen.main.bounds.width / CGFloat(cols)
        }
    }
    
//    // Compute cell size for delta mazes, with optional cols parameter
//    func computeDeltaCellSize(cols: Int? = nil) -> CGFloat {
//        // Use provided cols or calculate from generationSteps if available, default to 10
//        let effectiveCols = cols ?? (generationSteps.isEmpty ? 10 : (generationSteps[0].map { $0.x }.max() ?? 0) + 1)
//        let screenWidth = UIScreen.main.bounds.width
//        
//        // Define target paddings for two screen widths
//        let w1: CGFloat = 390.0  // Screen width 1 (e.g., iPhone 16e)
//        let p1: CGFloat = 42.0   // Target padding for w1
//        let w2: CGFloat = 400.0  // Screen width 2 (e.g., iPhone 16 Pro)
//        let p2: CGFloat = 45.0   // Target padding for w2
//        
//        // Calculate constants for padding = a + b * screenWidth
//        let b = (p2 - p1) / (w2 - w1)  // Slope
//        let a = p1 - b * w1            // Intercept
//        
//        // Compute padding for the current screen width
//        let padding = a + b * screenWidth
//        
//        // Calculate available width and return cell size
//        let available = screenWidth - padding * 2
//        return available * 2 / (CGFloat(effectiveCols) + 1)
//    }
    
    func computeDeltaCellSize(cols: Int? = nil) -> CGFloat {
        // Use provided cols or calculate from generationSteps if available, default to 10
        let effectiveCols = cols ?? (generationSteps.isEmpty ? 10 : (generationSteps[0].map { $0.x }.max() ?? 0) + 1)
        let screenWidth = UIScreen.main.bounds.width
        
        // Define target paddings for three screen widths
        let w1: CGFloat = 375.0  // iPhone SE (3rd generation)
        let p1: CGFloat = 50.0   // Increased padding for w1 (e.g., 36 instead of 30)
        let w2: CGFloat = 390.0  // iPhone 16e
        let p2: CGFloat = 38.0   // Desired padding for w2
        let w3: CGFloat = 400.0  // iPhone 16 Plus
        let p3: CGFloat = 52.0   // Desired padding for w3
        
        // Compute padding using piecewise linear interpolation
        let padding: CGFloat
        if screenWidth <= w1 {
            padding = p1
        } else if screenWidth < w2 {
            // Interpolate between w1 and w2
            let ratio = (screenWidth - w1) / (w2 - w1)
            padding = p1 + ratio * (p2 - p1)
        } else if screenWidth < w3 {
            // Interpolate between w2 and w3
            let ratio = (screenWidth - w2) / (w3 - w2)
            padding = p2 + ratio * (p3 - p2)
        } else {
            padding = p3
        }
        
        // Calculate available width and return cell size
        let available = screenWidth - padding * 2
        return available * 2 / (CGFloat(effectiveCols) + 1)
    }

    // Function to toggle heat map and update palette
    private func toggleHeatMap() {
        showHeatMap.toggle()
        if showHeatMap {
            selectedPalette = randomPaletteExcluding(current: selectedPalette, from: allPalettes)
            defaultBackground = randomDefaultExcluding(current: defaultBackground, from: defaultBackgroundColors)
        }
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

    var body: some View {
        VStack {
            // Navigation bar matching MazeRenderView, with fully functional buttons
            HStack(spacing: 16) {
                Button(action: {
                    mazeGenerated = false
                    isAnimatingGeneration = false // Added to exit animation state
//                    // Clear the generation steps from memory
//                    if let gridPtr = currentGrid {
//                        mazer_clear_generation_steps(gridPtr)
//                    }
                }) {
                    Image(systemName: "arrow.uturn.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Back to maze settings")

                Button(action: {
                    defaultBackground = defaultBackgroundColors.randomElement()!
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
            .padding(.top)

            if currentStepIndex < generationSteps.count {
                ZStack {
                    Group {
                        let currentCells = generationSteps[currentStepIndex]
                        switch mazeType {
                        case .orthogonal:
                            OrthogonalMazeView(
                                selectedPalette: .constant(wetAsphaltPalette),
                                cells: currentCells,
                                showSolution: showSolution,
                                showHeatMap: showHeatMap,
                                defaultBackgroundColor: defaultBackground
                            )
                            .id(currentStepIndex)  // Force re-render on each step
                        case .delta:
                            DeltaMazeView(
                                cells: currentCells,
                                cellSize: computeCellSize(),
                                showSolution: showSolution,
                                showHeatMap: showHeatMap,
                                selectedPalette: selectedPalette,
                                maxDistance: currentCells.map(\.distance).max() ?? 1,
                                defaultBackgroundColor: defaultBackground
                            )
                            .id(currentStepIndex)  // Force re-render on each step
                        case .sigma:
                            SigmaMazeView(
                                selectedPalette: .constant(wetAsphaltPalette),
                                cells: currentCells,
                                cellSize: computeCellSize(),
                                showSolution: showSolution,
                                showHeatMap: showHeatMap,
                                defaultBackgroundColor: defaultBackground
                            )
                            .id(currentStepIndex)  // Force re-render on each step
                        default:
                            Text("Unsupported maze type")
                        }
                    }

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
                                defaultBackground = defaultBackgroundColors.filter { $0 != defaultBackground }.randomElement() ?? defaultBackground
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
                                defaultBackground = defaultBackgroundColors.filter { $0 != defaultBackground }.randomElement() ?? defaultBackground
                            
//                                // Clear the generation steps from memory
//                                if let gridPtr = currentGrid {
//                                    mazer_clear_generation_steps(gridPtr)
//                                }
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
