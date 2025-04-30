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
    @Binding var showControls: Bool
    // track the arrow‐pad’s drag offset
    @Binding var padOffset: CGSize
    @Binding var selectedPalette: HeatMapPalette
    @Binding var mazeID: UUID
    // remember where we were when this drag began
    @State private var dragStartOffset: CGSize = .zero
    
    let mazeCells: [MazeCell]
    let mazeType: MazeType  // "Orthogonal", "Sigma", etc.
    
    let regenerateMaze: () -> Void
    // handle move actions (buttons and later swipe gestures)
    let moveAction: (String) -> Void
    let toggleHeatMap: () -> Void
    
    /// Always clear the solution overlay before making a move.
    private var performMove: (String) -> Void {
        { dir in
            showSolution = false
            moveAction(dir)
        }
    }
    
    func computeCellSize() -> CGFloat {
        let cols = (mazeCells.map { $0.x }.max() ?? 0) + 1

        switch mazeType {
        case .orthogonal:
          return UIScreen.main.bounds.width / CGFloat(cols)
        case .delta:
            return UIScreen.main.bounds.width / CGFloat(cols) * 1.35
        case .sigma:
          // flat-topped hex: total horizontal “units” =
          //   1 full cell + 1.5 for each additional column
          let units = 1.5 * CGFloat(cols - 1) + 1
          return UIScreen.main.bounds.width / units
        // TODO: .polar
        default:
          return UIScreen.main.bounds.width / CGFloat(cols)
        }
      }
    
    var columns: Int {
        (mazeCells.map { $0.x }.max() ?? 0) + 1
    }
    var rows: Int {
        (mazeCells.map { $0.y }.max() ?? 0) + 1
    }
    
    func computeDeltaCellSize() -> CGFloat {
      let padding: CGFloat = 44 // or however much you want on each side
      let available = UIScreen.main.bounds.width - padding*2
      return available * 2 / (CGFloat(columns) + 1)
    }

    
    @ViewBuilder
    private var directionControlView: some View {
        switch mazeType {
        case .orthogonal:
            OrthogonalDirectionControlView(moveAction: performMove)
                .id(mazeID) // Force view recreation when mazeID changes
                .padding(.top, 3)
        case .sigma:
            SigmaDirectionControlView(moveAction: performMove)
                .id(mazeID)
                .padding(.top, 3)
        case .delta:
            DeltaDirectionControlView(moveAction: performMove)
                .id(mazeID)
                .padding(.top, 3)
        case .polar:
            VStack(spacing: 8) {
                Image(systemName: "wrench.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)

                Text("Under Construction")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // A computed property to build the maze content based on mazeType.
    @ViewBuilder
    var mazeContent: some View {
        let cellSize = computeCellSize()
        switch mazeType {
        case .orthogonal:
            // TODO: pass cellSize into OrthogonalMazeView?
            OrthogonalMazeView(
                selectedPalette: $selectedPalette,
                cells: mazeCells,
                showSolution: showSolution,
                showHeatMap: showHeatMap
            )
            .id(mazeID)
        case .sigma:
            SigmaMazeView(
                selectedPalette: $selectedPalette,
                cells: mazeCells,
                cellSize: cellSize,
                showSolution: showSolution,
                showHeatMap: showHeatMap
            )
            .id(mazeID)
        case .delta:
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
        case .polar:
            VStack(spacing: 8) {
                Image(systemName: "wrench.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)

                Text("Under Construction")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
                Button(action: toggleHeatMap) {
                    Image(systemName: showHeatMap ? "flame.fill" : "flame")
                        .font(.title2)
                        .foregroundColor(showHeatMap ? .orange : .gray)
                }
                .accessibilityLabel("Toggle heat map")
                
                // Navigation controls toggle
                Button {
                    withAnimation { showControls.toggle() }
                } label: {
                    Image(systemName: showControls ? "xmark.circle.fill" : "ellipsis.circle")
                        .font(.title2)
                }
                .accessibilityLabel("Toggle navigation controls")
            }
            .padding(.top)
            
            
            
            // The maze container:
            if mazeType == .orthogonal || mazeType == .delta || mazeType == .sigma {
                ZStack {
                    mazeContent
                    if showControls {
                        VStack {
                            Spacer()
                            directionControlView
                                .fixedSize() // ↖️ stop it from growing to fill horizontally
                                .background(
                                    // either a solid color:
                                    Color(.systemBackground).opacity(0.8)
                                    // —or an iOS material:
                                    // .regularMaterial
                                )
                                .cornerRadius(16) // round the bubble
                                .shadow(radius: 4)
                            // apply the user’s drag offset
                                .offset(padOffset)
                            // let the pad itself handle drags to move its position
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            // add translation onto where we started
                                            padOffset = CGSize(
                                                width: dragStartOffset.width + value.translation.width,
                                                height: dragStartOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { value in
                                            // clamp it, then store it as the new “start” for next time
                                            let newOffset = CGSize(
                                                width: dragStartOffset.width + value.translation.width,
                                                height: dragStartOffset.height + value.translation.height
                                            )
                                            padOffset = clamped(offset: newOffset)
                                            dragStartOffset = padOffset
                                        }
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            // reset on toggle‐on:
                                .onChange(of: showControls) { newValue in
                                    guard newValue else { return }
                                    padOffset = .zero
                                    dragStartOffset = .zero
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            if mazeType == .orthogonal {
                                let hx = value.translation.width
                                let hy = value.translation.height
                                let dim = cellSize()
                                if abs(hx) > abs(hy) {
                                    let count = max(1, Int(round(abs(hx) / dim)))
                                    let dir = hx < 0 ? "Left" : "Right"
                                    for i in 0..<count {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                            performMove(dir)
                                        }
                                    }
                                } else {
                                    let count = max(1, Int(round(abs(hy) / dim)))
                                    let dir = hy < 0 ? "Up" : "Down"
                                    for i in 0..<count {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                            performMove(dir)
                                        }
                                    }
                                }
                            }
                            else if mazeType == .delta || mazeType == .sigma {
                                // purposefully negated (inverted) height so it would properly work in atan2's trig math
                                let tx = value.translation.width
                                let ty = -value.translation.height
                                
                                guard tx != 0 || ty != 0 else { return }
                                
                                // angle in [–π, π], shift by 22.5°
                                let angle = atan2(ty, tx)
                                var shifted = angle + (.pi / 8)
                                if shifted < 0 { shifted += 2 * .pi }
                                
                                // 8 equal 45° slices
                                let sector = Int(floor(shifted / (.pi / 4))) % 8
                                let directions = [
                                    "Right",      // 0
                                    "UpperRight", // 1
                                    "Up",         // 2
                                    "UpperLeft",  // 3
                                    "Left",       // 4
                                    "LowerLeft",  // 5
                                    "Down",       // 6
                                    "LowerRight"  // 7
                                ]
                                let chosen = directions[sector]
                                
                                // multiple moves by drag length
                                let mag = sqrt(tx*tx + ty*ty)
                                let dim = cellSize()
                                let count = max(1, Int(round(mag / dim)))
                                for i in 0..<count {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                        performMove(chosen)
                                    }
                                }
                            }
                        }
                )
                
            } else {
                // For other maze types, no gesture is attached.
                ZStack {
                    mazeContent
                    if showControls {
                        VStack {
                            Spacer()
                            directionControlView
                                .fixedSize() // ↖️ stop it from growing to fill horizontally
                                .background(
                                    // either a solid color:
                                    Color(.systemBackground).opacity(0.8)
                                    // —or an iOS material:
                                    // .regularMaterial
                                )
                                .cornerRadius(16) // round the bubble
                                .shadow(radius: 4)
                            // apply the user’s drag offset
                                .offset(padOffset)
                            // let the pad itself handle drags to move its position
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            // add translation onto where we started
                                            padOffset = CGSize(
                                                width: dragStartOffset.width + value.translation.width,
                                                height: dragStartOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { value in
                                            // clamp it, then store it as the new “start” for next time
                                            let newOffset = CGSize(
                                                width: dragStartOffset.width + value.translation.width,
                                                height: dragStartOffset.height + value.translation.height
                                            )
                                            padOffset = clamped(offset: newOffset)
                                            dragStartOffset = padOffset
                                        }
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            // reset on toggle‐on:
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
        }
    }
    
    private func clamped(offset: CGSize) -> CGSize {
        // e.g. ensure padOffset.x stays within ±screenWidth/2
        let maxX = UIScreen.main.bounds.width/2 - 50
        let maxY = UIScreen.main.bounds.height/2 - 50
        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }
    
    private func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
        guard showHeatMap, maxDistance > 0 else {
            return .gray  // fallback color when heat map is off
        }
        
        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    }
    
    
}

