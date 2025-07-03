//
//  MazeRenderView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI
import UIKit
import AudioToolbox // Added for sound playback

struct MazeRenderView: View {
    @Binding var mazeGenerated: Bool
    @Binding var showSolution: Bool
    @Binding var showHeatMap: Bool
    @Binding var showControls: Bool
    @Binding var padOffset: CGSize
    @Binding var selectedPalette: HeatMapPalette
    @Binding var mazeID: UUID
    @Binding var defaultBackground: Color
    @State private var dragStartOffset: CGSize = .zero
    // Add state for pinch zoom
    @State private var scale: CGFloat = 1.0
    @State private var anchorPoint: UnitPoint = .center

    let mazeCells: [MazeCell]
    let mazeType: MazeType
    let regenerateMaze: () -> Void
    let moveAction: (String) -> Void
    let cellSizes: (square: CGFloat, octagon: CGFloat)
    let toggleHeatMap: () -> Void
    let cleanupMazeData: () -> Void 

    private var performMove: (String) -> Void {
        { dir in
            showSolution = false
            moveAction(dir)
        }
    }

    var columns: Int {
        (mazeCells.map { $0.x }.max() ?? 0) + 1
    }

    var rows: Int {
        (mazeCells.map { $0.y }.max() ?? 0) + 1
    }
    
    @ViewBuilder
    private var directionControlView: some View {
        switch mazeType {
        case .orthogonal:
            FourWayControlView(moveAction: performMove)
                .id(mazeID)
                .padding(.top, 3)
        case .sigma:
            EightWayControlView(moveAction: performMove)
                .id(mazeID)
                .padding(.top, 3)
        case .delta:
            EightWayControlView(moveAction: performMove)
                .id(mazeID)
                .padding(.top, 3)
        case .upsilon:
            EightWayControlView(moveAction: performMove)
                .id(mazeID)
                .padding(.top, 3)
        case .rhombic:
            FourWayDiagonalControlView(moveAction: performMove)
                .id(mazeID)
                .padding(.top, 3)

        }
    }

    @ViewBuilder
    var mazeContent: some View {
        let cellSize = computeCellSize(mazeCells: mazeCells, mazeType: mazeType)
        switch mazeType {
        case .orthogonal:
            OrthogonalMazeView(
                selectedPalette: $selectedPalette,
                cells: mazeCells,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                defaultBackgroundColor: defaultBackground
            )
            .id(mazeID)
        case .sigma:
            SigmaMazeView(
                selectedPalette: $selectedPalette,
                cells: mazeCells,
                cellSize: cellSize,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                defaultBackgroundColor: defaultBackground
            )
            .id(mazeID)
        case .delta:
            let maxDistance = mazeCells.map { $0.distance }.max() ?? 1
            DeltaMazeView(
                cells: mazeCells,
                cellSize: cellSize,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                selectedPalette: selectedPalette,
                maxDistance: maxDistance,
                defaultBackgroundColor: defaultBackground
            )
            .id(mazeID)
        case .upsilon:
            UpsilonMazeView(
                cells: mazeCells,
                octagonSize: cellSizes.octagon,
                squareSize: cellSizes.square,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                selectedPalette: selectedPalette,
                defaultBackgroundColor: defaultBackground
            )
            .id(mazeID)
        
        case .rhombic:
            GeometryReader { geo in
                    // 1) Recompute the exact size of the diamond grid:
                    let maxX = mazeCells.map { $0.x }.max() ?? 0
                    let maxY = mazeCells.map { $0.y }.max() ?? 0

                    let sqrt2     = CGFloat(2).squareRoot()
                    let diagonal  = cellSize * sqrt2
                    let gridWidth  = diagonal * (CGFloat(maxX) + 1)
                    let gridHeight = diagonal * (CGFloat(maxY) + 1)

                    // 2) Compute the leftover space and split in half:
                    let offsetX = (geo.size.width  - gridWidth)  / 2
                    let offsetY = (geo.size.height - gridHeight) / 2
                

                    // 3) Place your tight‐framed rhombic view there:
                    RhombicMazeView(
                        selectedPalette: $selectedPalette,
                        cells:           mazeCells,
                        cellSize:        cellSize,
                        showSolution:    showSolution,
                        showHeatMap:     showHeatMap,
                        defaultBackgroundColor: defaultBackground
                    )
                    .id(mazeID)
                    .offset(x: offsetX, y: offsetY)
//                    .padding(rhombicPadding(cellSize: cellSize))
//                    .padding(.top, 7)
                }
        }
    }

    private func cellSize() -> CGFloat {
        let maxColumn = (mazeCells.map { $0.x }.max() ?? 0) + 1
        return UIScreen.main.bounds.width / CGFloat(maxColumn)
    }

    var body: some View {
        VStack {
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
                    defaultBackground = defaultBackgroundColors.randomElement()!
                    mazeID = UUID()
                    regenerateMaze()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
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
                }
                .accessibilityLabel("Toggle navigation controls")
            }
//            .offset(y: -24) // for iPhone Xr, Rhombic Med and Large
//            .offset(y: -14) // for iPhone Xr, Rhombic Tiny and Small
//            .offset(y: -14) // for iPhone 11 Pro, Rhombic Med and Large
//            .offset(y: -14) // for iPhone 11 Pro Max, Rhombic Tiny and Small
//            .offset(y: -20) // for iPhone 11 Pro Max, Rhombic Med
//            .offset(y: -22) // for iPhone 12 Pro Max, Rhombic Med
//            .offset(y: -28) // for iPhone 11 Pro Max, Rhombic Large
//            .offset(y: -28) // for iPhone 12 Pro Max, Rhombic Large
            .offset(y: -7) // for iPhone 16e, Rhombic all sizes
//            .offset(y: -3) // for iPhone 11 Pro, Rhombic Tiny and Small
            // Rhombic mazes are simply too large for iPhone SE 2nd gen, will need to reduce number of rows
//            .offset(y: -9) // for iPhone 11, Rhombic Tiny and Small
//            .offset(y: -24) // for iPhone 11, Rhombic Med
//            .offset(y: -26) // for iPhone 11, Rhombic Large
//            .offset(y: -9) // for iPhone 12, Rhombic Tiny and Small
//            .offset(y: -9) // for iPhone 12 Pro, Rhombic Tiny and Small
//            .offset(y: -12) // for iPhone 12, Rhombic Med and Large
//            .offset(y: -12) // for iPhone 12 Pro, Rhombic Med and Large
//            .offset(y: -16) // for iPhone 12 Pro Max, Rhombic Tiny and Small

            
            

            ZStack {
                mazeContent
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onEnded { value in
                                let batchSize = 1
                                let tx = value.translation.width
                                let ty = -value.translation.height
                                guard tx != 0 || ty != 0 else { return }
                                let angle = atan2(ty, tx)
                                var shifted = angle + (.pi / 8)
                                if shifted < 0 { shifted += 2 * .pi }
                                let sector = Int(floor(shifted / (.pi / 4))) % 8
                                let directions = [
                                    "Right", "UpperRight", "Up", "UpperLeft",
                                    "Left", "LowerLeft", "Down", "LowerRight"
                                ]
                                let chosen = directions[sector]
                                let mag = sqrt(tx*tx + ty*ty)
                                let baseDim = computeCellSize(mazeCells: mazeCells, mazeType: mazeType)
                                let dim: CGFloat
                                switch mazeType {
                                case .sigma:
                                    dim = baseDim * sqrt(3) // Hex cell center distance
                                case .orthogonal:
                                    dim = baseDim           // Square cell distance
                                case .delta:
                                    dim = baseDim / sqrt(3) // Triangular cell center distance
                                default:
                                    dim = baseDim
                                }
                                let totalMoves = max(1, Int(round(mag / dim)))
                                let movesToPerform = min(totalMoves, batchSize)
                                for _ in 0..<movesToPerform {
                                    performMove(chosen)
                                }
                                if totalMoves > batchSize {
                                    for i in batchSize..<totalMoves {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                            performMove(chosen)
                                        }
                                    }
                                }
                            }
                    )
                
                if showControls {
                    VStack {
                        Spacer()
                        directionControlView
                            .fixedSize()
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                            .offset(padOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        padOffset = CGSize(
                                            width: dragStartOffset.width + value.translation.width,
                                            height: dragStartOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { value in
                                        let newOffset = CGSize(
                                            width: dragStartOffset.width + value.translation.width,
                                            height: dragStartOffset.height + value.translation.height
                                        )
                                        padOffset = clamped(offset: newOffset)
                                        dragStartOffset = padOffset
                                    }
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onChange(of: showControls) { newValue in
                                guard newValue else { return }
                                padOffset = .zero
                                dragStartOffset = .zero
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            AudioServicesPlaySystemSound(1104)
        }
    }
//
//    var body: some View {
//        VStack {
//            HStack(spacing: 16) {
//                Button(action: {
//                    cleanupMazeData()
//                }) {
//                    Image(systemName: "arrow.uturn.left")
//                        .font(.title2)
//                        .foregroundColor(.blue)
//                }
//                .accessibilityLabel("Back to maze settings")
//
//                Button(action: {
//                    defaultBackground = defaultBackgroundColors.randomElement()!
//                    mazeID = UUID()
//                    regenerateMaze()
//                }) {
//                    Image(systemName: "arrow.clockwise")
//                        .font(.title2)
//                        .foregroundColor(.purple)
//                }
//                .accessibilityLabel("Generate new maze")
//
//                Button(action: {
//                    showSolution.toggle()
//                }) {
//                    Image(systemName: showSolution ? "checkmark.circle.fill" : "checkmark.circle")
//                        .font(.title2)
//                        .foregroundColor(showSolution ? .green : .gray)
//                }
//                .accessibilityLabel("Toggle solution path")
//
//                Button(action: toggleHeatMap) {
//                    Image(systemName: showHeatMap ? "flame.fill" : "flame")
//                        .font(.title2)
//                        .foregroundColor(showHeatMap ? .orange : .gray)
//                }
//                .accessibilityLabel("Toggle heat map")
//
//                Button {
//                    withAnimation { showControls.toggle() }
//                } label: {
//                    Image(systemName: showControls ? "xmark.circle.fill" : "ellipsis.circle")
//                        .font(.title2)
//                }
//                .accessibilityLabel("Toggle navigation controls")
//            }
////            .padding(.top)
//            
//            ZStack {
//                mazeContent
//                    .gesture(
//                        DragGesture(minimumDistance: 10)
//                            .onEnded { value in
//                                let batchSize = 1
//                                let tx = value.translation.width
//                                let ty = -value.translation.height
//                                guard tx != 0 || ty != 0 else { return }
//                                let angle = atan2(ty, tx)
//                                var shifted = angle + (.pi / 8)
//                                if shifted < 0 { shifted += 2 * .pi }
//                                let sector = Int(floor(shifted / (.pi / 4))) % 8
//                                let directions = [
//                                    "Right", "UpperRight", "Up", "UpperLeft",
//                                    "Left", "LowerLeft", "Down", "LowerRight"
//                                ]
//                                let chosen = directions[sector]
//                                let mag = sqrt(tx*tx + ty*ty)
//                                let baseDim = computeCellSize(mazeCells: mazeCells, mazeType: mazeType)
//                                let dim: CGFloat
//                                switch mazeType {
//                                case .sigma:
//                                    dim = baseDim * sqrt(3) // Hex cell center distance
//                                case .orthogonal:
//                                    dim = baseDim           // Square cell distance
//                                case .delta:
//                                    dim = baseDim / sqrt(3) // Triangular cell center distance
//                                default:
//                                    dim = baseDim
//                                }
//                                let totalMoves = max(1, Int(round(mag / dim)))
//                                let movesToPerform = min(totalMoves, batchSize)
//                                for _ in 0..<movesToPerform {
//                                    performMove(chosen)
//                                }
//                                if totalMoves > batchSize {
//                                    for i in batchSize..<totalMoves {
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
//                                            performMove(chosen)
//                                        }
//                                    }
//                                }
//                            }
//                    )
//                
//                if showControls {
//                    VStack {
//                        Spacer()
//                        directionControlView
//                            .fixedSize()
//                            .background(Color(.systemBackground).opacity(0.8))
//                            .cornerRadius(16)
//                            .shadow(radius: 4)
//                            .offset(padOffset)
//                            .gesture(
//                                DragGesture()
//                                    .onChanged { value in
//                                        padOffset = CGSize(
//                                            width: dragStartOffset.width + value.translation.width,
//                                            height: dragStartOffset.height + value.translation.height
//                                        )
//                                    }
//                                    .onEnded { value in
//                                        let newOffset = CGSize(
//                                            width: dragStartOffset.width + value.translation.width,
//                                            height: dragStartOffset.height + value.translation.height
//                                        )
//                                        padOffset = clamped(offset: newOffset)
//                                        dragStartOffset = padOffset
//                                    }
//                            )
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                            .onChange(of: showControls) { newValue in
//                                guard newValue else { return }
//                                padOffset = .zero
//                                dragStartOffset = .zero
//                            }
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//        }
//        .onAppear {
//            // Play sound when MazeRenderView appears
//            AudioServicesPlaySystemSound(1104)
//        }
//    }

    private func clamped(offset: CGSize) -> CGSize {
        let maxX = UIScreen.main.bounds.width / 2 - 50
        let maxY = UIScreen.main.bounds.height / 2 - 50
        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }

    private func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
        guard showHeatMap, maxDistance > 0 else {
            return .gray
        }
        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    }
}

