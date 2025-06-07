//
//  MazeGenerationAnimationView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 6/6/25.
//

import SwiftUI

struct MazeGenerationAnimationView: View {
    let generationSteps: [[MazeCell]]
    let mazeType: MazeType
    @Binding var isAnimatingGeneration: Bool
    @Binding var mazeGenerated: Bool

    @State private var currentStepIndex = 0

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
                case .sigma:
                    SigmaMazeView(
                        selectedPalette: .constant(wetAsphaltPalette),
                        cells: currentCells,
                        cellSize: computeCellSize(),
                        showSolution: false,
                        showHeatMap: false,
                        defaultBackgroundColor: .gray
                    )
                default:
                    Text("Unsupported maze type")
                }
            }
            .onAppear {
                for i in 0..<generationSteps.count {
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
