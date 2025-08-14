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
    @Binding var showHelp: Bool
    @State private var dragStartOffset: CGSize = .zero
    // Add state for pinch zoom
    @State private var scale: CGFloat = 1.0
    @State private var anchorPoint: UnitPoint = .center
    @State private var lastLocation: CGPoint? = nil
    @State private var cumulativePathLength: CGFloat = 0.0
    @State private var directionVector: CGSize = .zero
    @State private var lastMoveDirection: String? = nil
    @State private var performedMoves: Int = 0
    
    let mazeCells: [MazeCell]
    let mazeType: MazeType
    let cellSize: CellSize
    let optionalColor: Color?
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
    
    private var horizontalAdjustment: CGFloat {
        navigationMenuHorizontalAdjustment(mazeType: mazeType, cellSize: cellSize)
    }
    
    private var verticalAdjustment: CGFloat {
        navigationMenuVerticalAdjustment(mazeType: mazeType, cellSize: cellSize)
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
        let cellSize = computeCellSize(mazeCells: mazeCells, mazeType: mazeType, cellSize: cellSize)
        switch mazeType {
        case .orthogonal:
            OrthogonalMazeView(
                selectedPalette: $selectedPalette,
                cells: mazeCells,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
            )
            .id(mazeID)
        case .sigma:
            SigmaMazeView(
                selectedPalette: $selectedPalette,
                cells: mazeCells,
                cellSize: cellSize,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
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
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
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
                defaultBackgroundColor: defaultBackground,
                optionalColor: optionalColor
            )
            .id(mazeID)
        case .rhombic:
            GeometryReader { geo in
                // 1) Recompute the exact size of the diamond grid:
                let maxX = mazeCells.map { $0.x }.max() ?? 0
                let maxY = mazeCells.map { $0.y }.max() ?? 0
                
                let sqrt2 = CGFloat(2).squareRoot()
                let diagonal = cellSize * sqrt2
                let gridWidth = diagonal * (CGFloat(maxX) + 1)
                let gridHeight = diagonal * (CGFloat(maxY) + 1)
                
                // 2) Compute the leftover space and split in half:
                let offsetX = (geo.size.width - gridWidth) / 2
                let offsetY = (geo.size.height - gridHeight) / 2
                
                // 3) Place your tight‐framed rhombic view there:
                RhombicMazeView(
                    selectedPalette: $selectedPalette,
                    cells: mazeCells,
                    cellSize: cellSize,
                    showSolution: showSolution,
                    showHeatMap: showHeatMap,
                    defaultBackgroundColor: defaultBackground,
                    optionalColor: optionalColor
                )
                .id(mazeID)
                .offset(x: offsetX, y: offsetY)
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Button(action: {
                    cleanupMazeData()
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Back to maze settings")
                
                Button(action: {
                    showSolution = false
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
                
                Button {
                    showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .accessibilityLabel("Help instructions")
            }
            .offset(x: horizontalAdjustment, y: verticalAdjustment)
            
            ZStack {
                mazeContent
                
                if showControls {
                    VStack {
                        Spacer()
                        directionControlView
                            .fixedSize()
//                            .background(Color(.systemBackground).opacity(0.8))
//                            .cornerRadius(16)
//                            .shadow(radius: 4)
                            .background(Color(.systemBackground).opacity(0.0))
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
                    }
                }
            }
            .onChange(of: showControls) { newValue in
                if newValue {
                    padOffset = .zero
                    dragStartOffset = .zero
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if lastLocation == nil {
                            lastLocation = value.location
                            return
                        }
                        
                        let currentLocation = value.location
                        let deltaX = currentLocation.x - lastLocation!.x
                        let deltaY = currentLocation.y - lastLocation!.y
                        lastLocation = currentLocation
                        
                        let delta_tx = deltaX
                        let delta_ty = -deltaY
                        let delta_mag = sqrt(delta_tx * delta_tx + delta_ty * delta_ty)
                        if delta_mag == 0 { return }
                        
                        cumulativePathLength += delta_mag
                        
                        // Update directionVector with exponential moving average (alpha = 0.3 for responsiveness)
                        let alpha: CGFloat = 0.3
                        if directionVector == .zero {
                            directionVector = CGSize(width: delta_tx, height: delta_ty)
                        } else {
                            directionVector = CGSize(
                                width: directionVector.width * alpha + delta_tx * (1 - alpha),
                                height: directionVector.height * alpha + delta_ty * (1 - alpha)
                            )
                        }
                        
                        // Skip if directionVector is zero (though unlikely)
                        if directionVector.width == 0 && directionVector.height == 0 { return }
                        
                        // Determine current direction from directionVector
                        let angle = atan2(directionVector.height, directionVector.width)
                        var shifted = angle + (.pi / 8)
                        if shifted < 0 { shifted += 2 * .pi }
                        let sector = Int(floor(shifted / (.pi / 4))) % 8
                        let directions = [
                            "Right", "UpperRight", "Up", "UpperLeft",
                            "Left", "LowerLeft", "Down", "LowerRight"
                        ]
                        let currentDirection = directions[sector]
                        lastMoveDirection = currentDirection
                        
                        // Calculate total moves needed based on path length
                        let baseDim = computeCellSize(mazeCells: mazeCells, mazeType: mazeType, cellSize: cellSize)
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
                        
                        let totalMovesNeeded = Int(floor(cumulativePathLength / dim))
                        let movesToPerform = totalMovesNeeded - performedMoves
                        
                        // Perform incremental moves live
                        if movesToPerform > 0 {
                            for _ in 0..<movesToPerform {
                                performMove(currentDirection)
                            }
                            performedMoves += movesToPerform
                        }
                    }
                    .onEnded { value in
                        // Handle finalization with rounding for any fractional path length
                        let baseDim = computeCellSize(mazeCells: mazeCells, mazeType: mazeType, cellSize: cellSize)
                        let dim: CGFloat
                        switch mazeType {
                        case .sigma:
                            dim = baseDim * sqrt(3)
                        case .orthogonal:
                            dim = baseDim
                        case .delta:
                            dim = baseDim / sqrt(3)
                        default:
                            dim = baseDim
                        }
                        
                        let totalMoves = Int(round(cumulativePathLength / dim))
                        let remainingMoves = totalMoves - performedMoves
                        
                        if remainingMoves > 0, let direction = lastMoveDirection {
                            let batchSize = 1
                            let movesToPerform = min(remainingMoves, batchSize)
                            for _ in 0..<movesToPerform {
                                performMove(direction)
                            }
                            if remainingMoves > batchSize {
                                for i in batchSize..<remainingMoves {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                        performMove(direction)
                                    }
                                }
                            }
                        }
                        
                        // Reset states for next gesture
                        lastLocation = nil
                        cumulativePathLength = 0.0
                        directionVector = .zero
                        lastMoveDirection = nil
                        performedMoves = 0
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            let key = "hasSeenHelpInstructions"
            let hasSeen = UserDefaults.standard.bool(forKey: key)
            if !hasSeen {
                showHelp = true
                UserDefaults.standard.set(true, forKey: key)
            }
            
            // AudioServicesPlaySystemSound(1104)
        }
    }
    
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
