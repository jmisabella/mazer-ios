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
    let toggleHeatMap: () -> Void

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
            return computeDeltaCellSize()
        case .sigma:
            let units = 1.5 * CGFloat(cols - 1) + 1
            return UIScreen.main.bounds.width / units
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
        let screenWidth = UIScreen.main.bounds.width
        
        // Define target paddings for two screen widths
        let w1: CGFloat = 390.0  // Screen width 1 (e.g., iPhone 16e)
        let p1: CGFloat = 42.0   // Target padding for w1
        let w2: CGFloat = 400.0  // Screen width 2 (e.g., iPhone 16 Pro)
        let p2: CGFloat = 45.0   // Target padding for w2 (reduced from 51)
        
        // Calculate constants for padding = a + b * screenWidth
        let b = (p2 - p1) / (w2 - w1)  // Slope
        let a = p1 - b * w1            // Intercept
        
        // Compute padding for the current screen width
        let padding = a + b * screenWidth
        
        // Calculate available width and return cell size
        let available = screenWidth - padding * 2
        return available * 2 / (CGFloat(columns) + 1) // Assuming 'columns' is defined
    }
    
    @ViewBuilder
    private var directionControlView: some View {
        switch mazeType {
        case .orthogonal:
            OrthogonalDirectionControlView(moveAction: performMove)
                .id(mazeID)
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

    @ViewBuilder
    var mazeContent: some View {
        let cellSize = computeCellSize()
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

    private func cellSize() -> CGFloat {
        let maxColumn = (mazeCells.map { $0.x }.max() ?? 0) + 1
        return UIScreen.main.bounds.width / CGFloat(maxColumn)
    }

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Button(action: {
                    mazeGenerated = false
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
            .padding(.top)

            if mazeType == .orthogonal || mazeType == .delta || mazeType == .sigma {
                ZStack {
                    mazeContent
                        .scaleEffect(scale, anchor: anchorPoint)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    // Cap the scale between 1.0 and 3.0
                                    scale = min(max(value, 1.0), 3.0)
                                    anchorPoint = .center // Center zoom for simplicity
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        scale = 1.0
                                        anchorPoint = .center
                                    }
                                }
                        )
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
                                    let baseDim = computeCellSize()
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
            } else {
                ZStack {
                    mazeContent
                        .scaleEffect(scale, anchor: anchorPoint)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = min(max(value, 1.0), 3.0)
                                    anchorPoint = .center
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        scale = 1.0
                                        anchorPoint = .center
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
        }
        .onAppear {
            // Play sound when MazeRenderView appears
            AudioServicesPlaySystemSound(1104)
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

//struct MazeRenderView: View {
//    @Binding var mazeGenerated: Bool
//    @Binding var showSolution: Bool
//    @Binding var showHeatMap: Bool
//    @Binding var showControls: Bool
//    @Binding var padOffset: CGSize
//    @Binding var selectedPalette: HeatMapPalette
//    @Binding var mazeID: UUID
//    @Binding var defaultBackground: Color
//    @State private var dragStartOffset: CGSize = .zero
//    // Add state for pinch zoom
//    @State private var scale: CGFloat = 1.0
//    @State private var anchorPoint: UnitPoint = .center
//
//    let mazeCells: [MazeCell]
//    let mazeType: MazeType
//    let regenerateMaze: () -> Void
//    let moveAction: (String) -> Void
//    let toggleHeatMap: () -> Void
//
//    private var performMove: (String) -> Void {
//        { dir in
//            showSolution = false
//            moveAction(dir)
//        }
//    }
//
//    func computeCellSize() -> CGFloat {
//        let cols = (mazeCells.map { $0.x }.max() ?? 0) + 1
//        switch mazeType {
//        case .orthogonal:
//            return UIScreen.main.bounds.width / CGFloat(cols)
//        case .delta:
//            return computeDeltaCellSize()
//        case .sigma:
//            let units = 1.5 * CGFloat(cols - 1) + 1
//            return UIScreen.main.bounds.width / units
//        default:
//            return UIScreen.main.bounds.width / CGFloat(cols)
//        }
//    }
//
//    var columns: Int {
//        (mazeCells.map { $0.x }.max() ?? 0) + 1
//    }
//
//    var rows: Int {
//        (mazeCells.map { $0.y }.max() ?? 0) + 1
//    }
//
//    func computeDeltaCellSize() -> CGFloat {
//        let padding: CGFloat = 40
//        let available = UIScreen.main.bounds.width - padding * 2
//        return available * 2 / (CGFloat(columns) + 1)
//    }
//
//    @ViewBuilder
//    private var directionControlView: some View {
//        switch mazeType {
//        case .orthogonal:
//            OrthogonalDirectionControlView(moveAction: performMove)
//                .id(mazeID)
//                .padding(.top, 3)
//        case .sigma:
//            SigmaDirectionControlView(moveAction: performMove)
//                .id(mazeID)
//                .padding(.top, 3)
//        case .delta:
//            DeltaDirectionControlView(moveAction: performMove)
//                .id(mazeID)
//                .padding(.top, 3)
//        case .polar:
//            VStack(spacing: 8) {
//                Image(systemName: "wrench.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.gray)
//                Text("Under Construction")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//        }
//    }
//
//    @ViewBuilder
//    var mazeContent: some View {
//        let cellSize = computeCellSize()
//        switch mazeType {
//        case .orthogonal:
//            OrthogonalMazeView(
//                selectedPalette: $selectedPalette,
//                cells: mazeCells,
//                showSolution: showSolution,
//                showHeatMap: showHeatMap,
//                defaultBackgroundColor: defaultBackground
//            )
//            .id(mazeID)
//        case .sigma:
//            SigmaMazeView(
//                selectedPalette: $selectedPalette,
//                cells: mazeCells,
//                cellSize: cellSize,
//                showSolution: showSolution,
//                showHeatMap: showHeatMap,
//                defaultBackgroundColor: defaultBackground
//            )
//            .id(mazeID)
//        case .delta:
//            let maxDistance = mazeCells.map { $0.distance }.max() ?? 1
//            DeltaMazeView(
//                cells: mazeCells,
//                cellSize: cellSize,
//                showSolution: showSolution,
//                showHeatMap: showHeatMap,
//                selectedPalette: selectedPalette,
//                maxDistance: maxDistance,
//                defaultBackgroundColor: defaultBackground
//            )
//            .id(mazeID)
//        case .polar:
//            VStack(spacing: 8) {
//                Image(systemName: "wrench.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.gray)
//                Text("Under Construction")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//        }
//    }
//
//    private func cellSize() -> CGFloat {
//        let maxColumn = (mazeCells.map { $0.x }.max() ?? 0) + 1
//        return UIScreen.main.bounds.width / CGFloat(maxColumn)
//    }
//
//    var body: some View {
//        VStack {
//            HStack(spacing: 16) {
//                Button(action: {
//                    mazeGenerated = false
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
//            .padding(.top)
//
//            if mazeType == .orthogonal || mazeType == .delta || mazeType == .sigma {
//                ZStack {
//                    mazeContent
//                        .scaleEffect(scale, anchor: anchorPoint)
//                        .gesture(
//                            MagnificationGesture()
//                                .onChanged { value in
//                                    // Cap the scale between 1.0 and 3.0
//                                    scale = min(max(value, 1.0), 3.0)
//                                    anchorPoint = .center // Center zoom for simplicity
//                                }
//                                .onEnded { _ in
//                                    withAnimation(.easeOut(duration: 0.3)) {
//                                        scale = 1.0
//                                        anchorPoint = .center
//                                    }
//                                }
//                        )
//                        .gesture(
//                            DragGesture(minimumDistance: 10)
//                                .onEnded { value in
////                                    let isIPad = UIDevice.current.userInterfaceIdiom == .pad
//                                    let batchSize = 1
//                                    let tx = value.translation.width
//                                    let ty = -value.translation.height
//                                    guard tx != 0 || ty != 0 else { return }
//                                    let angle = atan2(ty, tx)
//                                    var shifted = angle + (.pi / 8)
//                                    if shifted < 0 { shifted += 2 * .pi }
//                                    let sector = Int(floor(shifted / (.pi / 4))) % 8
//                                    let directions = [
//                                        "Right", "UpperRight", "Up", "UpperLeft",
//                                        "Left", "LowerLeft", "Down", "LowerRight"
//                                    ]
//                                    let chosen = directions[sector]
//                                    let mag = sqrt(tx*tx + ty*ty)
//                                    let dim = computeCellSize()
//                                    let totalMoves = max(1, Int(round(mag / dim)))
//                                    let movesToPerform = min(totalMoves, batchSize)
//
//                                    for _ in 0..<movesToPerform {
//                                        performMove(chosen)
//                                    }
//
//                                    if totalMoves > batchSize {
//                                        for i in batchSize..<totalMoves {
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
//                                                performMove(chosen)
//                                            }
//                                        }
//                                    }
//                                }
//                        )
//
//                    if showControls {
//                        VStack {
//                            Spacer()
//                            directionControlView
//                                .fixedSize()
//                                .background(Color(.systemBackground).opacity(0.8))
//                                .cornerRadius(16)
//                                .shadow(radius: 4)
//                                .offset(padOffset)
//                                .gesture(
//                                    DragGesture()
//                                        .onChanged { value in
//                                            padOffset = CGSize(
//                                                width: dragStartOffset.width + value.translation.width,
//                                                height: dragStartOffset.height + value.translation.height
//                                            )
//                                        }
//                                        .onEnded { value in
//                                            let newOffset = CGSize(
//                                                width: dragStartOffset.width + value.translation.width,
//                                                height: dragStartOffset.height + value.translation.height
//                                            )
//                                            padOffset = clamped(offset: newOffset)
//                                            dragStartOffset = padOffset
//                                        }
//                                )
//                                .transition(.move(edge: .bottom).combined(with: .opacity))
//                                .onChange(of: showControls) { newValue in
//                                    guard newValue else { return }
//                                    padOffset = .zero
//                                    dragStartOffset = .zero
//                                }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else {
//                ZStack {
//                    mazeContent
//                        .scaleEffect(scale, anchor: anchorPoint)
//                        .gesture(
//                            MagnificationGesture()
//                                .onChanged { value in
//                                    scale = min(max(value, 1.0), 3.0)
//                                    anchorPoint = .center
//                                }
//                                .onEnded { _ in
//                                    withAnimation(.easeOut(duration: 0.3)) {
//                                        scale = 1.0
//                                        anchorPoint = .center
//                                    }
//                                }
//                        )
//                    if showControls {
//                        VStack {
//                            Spacer()
//                            directionControlView
//                                .fixedSize()
//                                .background(Color(.systemBackground).opacity(0.8))
//                                .cornerRadius(16)
//                                .shadow(radius: 4)
//                                .offset(padOffset)
//                                .gesture(
//                                    DragGesture()
//                                        .onChanged { value in
//                                            padOffset = CGSize(
//                                                width: dragStartOffset.width + value.translation.width,
//                                                height: dragStartOffset.height + value.translation.height
//                                            )
//                                        }
//                                        .onEnded { value in
//                                            let newOffset = CGSize(
//                                                width: dragStartOffset.width + value.translation.width,
//                                                height: dragStartOffset.height + value.translation.height
//                                            )
//                                            padOffset = clamped(offset: newOffset)
//                                            dragStartOffset = padOffset
//                                        }
//                                )
//                                .transition(.move(edge: .bottom).combined(with: .opacity))
//                                .onChange(of: showControls) { newValue in
//                                    guard newValue else { return }
//                                    padOffset = .zero
//                                    dragStartOffset = .zero
//                                }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
//    }
//
//    private func clamped(offset: CGSize) -> CGSize {
//        let maxX = UIScreen.main.bounds.width / 2 - 50
//        let maxY = UIScreen.main.bounds.height / 2 - 50
//        return CGSize(
//            width: min(max(offset.width, -maxX), maxX),
//            height: min(max(offset.height, -maxY), maxY)
//        )
//    }
//
//    private func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
//        guard showHeatMap, maxDistance > 0 else {
//            return .gray
//        }
//        let index = min(9, (cell.distance * 10) / maxDistance)
//        return selectedPalette.shades[index].asColor
//    }
//}
//
