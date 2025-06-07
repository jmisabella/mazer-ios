//
//  MazeGenerationAnimationView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/6/25.
//

import SwiftUI

struct MazeGenerationAnimationView: View {
    let generationSteps: [[MazeCell]]  // Array of maze generation steps
    let mazeType: MazeType             // Type of maze for rendering
    @Binding var isAnimatingGeneration: Bool  // Controls animation visibility
    @Binding var mazeGenerated: Bool          // Triggers MazeRenderView

    @State private var currentStepIndex = 0   // Tracks current animation step

    // Compute cell size based on maze type, consistent with MazeRenderView
    func computeCellSize() -> CGFloat {
        let cols = (generationSteps[0].map { $0.x }.max() ?? 0) + 1
        switch mazeType {
        case .orthogonal:
            return UIScreen.main.bounds.width / CGFloat(cols)
        case .delta:
            let padding: CGFloat = 40
            let available = UIScreen.main.bounds.width - padding * 2
            return available * 2 / (CGFloat(cols) + 1)
        case .sigma:
            let units = 1.5 * CGFloat(cols - 1) + 1
            return UIScreen.main.bounds.width / units
        default:
            return UIScreen.main.bounds.width / CGFloat(cols)
        }
    }

    var body: some View {
        if currentStepIndex < generationSteps.count {
//            Text("Step \(currentStepIndex)")
            Group {
                let currentCells = generationSteps[currentStepIndex]
                switch mazeType {
                case .orthogonal:
                    OrthogonalMazeView(
                        selectedPalette: .constant(wetAsphaltPalette),
                        cells: currentCells,
                        showSolution: false,
                        showHeatMap: false,
                        defaultBackgroundColor: .gray
                    )
                    .id(currentStepIndex)  // Force re-render on each step
                case .delta:
                    DeltaMazeView(
                        cells: currentCells,
                        cellSize: computeCellSize(),
                        showSolution: false,
                        showHeatMap: false,
                        selectedPalette: wetAsphaltPalette,
                        maxDistance: currentCells.map(\.distance).max() ?? 1,
                        defaultBackgroundColor: .gray
                    )
                    .id(currentStepIndex)  // Force re-render on each step
                case .sigma:
                    SigmaMazeView(
                        selectedPalette: .constant(wetAsphaltPalette),
                        cells: currentCells,
                        cellSize: computeCellSize(),
                        showSolution: false,
                        showHeatMap: false,
                        defaultBackgroundColor: .gray
                    )
                    .id(currentStepIndex)  // Force re-render on each step
                default:
                    Text("Unsupported maze type")
                }
            }
            .onAppear {
                for i in 0..<generationSteps.count {
                    let stepCells = generationSteps[i]
//                    print("Step \(i): first cell linked = \(stepCells.first?.linked ?? [])")
                    for (j, cell) in stepCells.enumerated() {
                        print("Step \(i), cell \(j): linked = \(cell.linked)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                        currentStepIndex = i
                        if i == generationSteps.count - 1 {
                            isAnimatingGeneration = false
                            mazeGenerated = true
                        }
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}
