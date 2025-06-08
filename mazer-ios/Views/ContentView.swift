//
//  ContentView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 3/26/25.
//

import SwiftUI
import AudioToolbox
import UIKit  // for UIFeedbackGenerator

// Grid Quest: Omni Mazes & Solver

struct ContentView: View {
    @State private var ffi_integration_test_result: Int32 = 0
    @State private var mazeCells: [MazeCell] = []
    @State private var mazeType: MazeType = .orthogonal
    @State private var mazeGenerated: Bool = false
    @State private var errorMessage: String?

    // User selections from request view
    @State private var selectedSize: MazeSize = .large
    @State private var selectedMazeType: MazeType = .orthogonal
    @State private var selectedAlgorithm: MazeAlgorithm = .recursiveBacktracker
    // User selections from render view
    @State private var showSolution: Bool = false
    @State private var showHeatMap: Bool = true
    @State private var showControls: Bool = false
    // track the arrow‐pad’s drag offset
    @State private var padOffset = CGSize(width: 0, height: 0)
    @State private var showCelebration: Bool = false
    // heat map palette
    @State private var selectedPalette: HeatMapPalette = allPalettes.randomElement()!
    @State private var mazeID = UUID()

    // Track the opaque maze pointer.
    @State private var currentGrid: OpaquePointer? = nil
    
    // default background for “non-heatmap” cells
    @State private var defaultBackgroundColor: Color = defaultBackgroundColors.randomElement()!
    
    @State private var didInitialRandomization = false
        
    @State private var hasPlayedSoundThisSession: Bool = false // Add this to track sound playback per session
    
    @State private var captureSteps: Bool = false
    @State private var isGeneratingMaze: Bool = false
    @State private var isAnimatingGeneration: Bool = false
    @State private var generationSteps: [[MazeCell]] = []
    @State private var isLoading: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase // Add this to detect app lifecycle changes
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    private func randomDefaultExcluding(
            current: Color,
            from all: [Color]
        ) -> Color {
            let others = all.filter { $0 != current }
            return others.randomElement() ?? current
        }
    
    var body: some View {
        ZStack {
            // 1) conditional full-screen background
            Group {
                if mazeGenerated {
//                    Color.black
                    colorScheme == .dark ? Color.black : Color.offWhite
                } else {
//                    Color(.systemBackground)
                    colorScheme == .dark ? Color.black : Color.offWhite
                }
            }
            
            .ignoresSafeArea()
            VStack {
                if isGeneratingMaze {
                    ProgressView("Generating maze...")
                } else if isAnimatingGeneration {
                    MazeGenerationAnimationView(
                        generationSteps: generationSteps,
                        mazeType: mazeType,
                        isAnimatingGeneration: $isAnimatingGeneration,
                        mazeGenerated: $mazeGenerated,
                        showSolution: $showSolution,
                        showHeatMap: $showHeatMap,
                        showControls: $showControls,
                        selectedPalette: $selectedPalette,
                        defaultBackground: $defaultBackgroundColor,
                        mazeID: $mazeID,
                        regenerateMaze: {
                            submitMazeRequest()
                        }
                    )
                } else if mazeGenerated {
                    MazeRenderView(
                        mazeGenerated: $mazeGenerated,
                        showSolution: $showSolution,
                        showHeatMap: $showHeatMap,
                        showControls: $showControls,
                        padOffset: $padOffset,
                        selectedPalette: $selectedPalette,
                        mazeID: $mazeID,
                        defaultBackground: $defaultBackgroundColor,
                        mazeCells: mazeCells,
                        mazeType: mazeType,
                        regenerateMaze: {
                            submitMazeRequest()
                        },
                        moveAction: { direction in
                            performMove(direction: direction)
                        },
                        toggleHeatMap: {
                            showHeatMap.toggle()
                            if showHeatMap {
                                // only pick a new one when turning it back on
                                selectedPalette = randomPaletteExcluding(current: selectedPalette, from: allPalettes)
                                // … and a new default background
                                defaultBackgroundColor = randomDefaultExcluding(
                                    current: defaultBackgroundColor,
                                    from: defaultBackgroundColors
                                )
                            }
                        }
                    )
                    .environment(\.colorScheme, .dark)
                    .padding(.vertical, 100)
                    .grayscale(showCelebration ? 1 : 0)
                    .animation(.easeInOut(duration: 0.65), value: showCelebration)
                } else {
                    MazeRequestView(
                        mazeCells: $mazeCells,
                        mazeGenerated: $mazeGenerated,
                        mazeType: $mazeType,
                        selectedSize: $selectedSize,
                        selectedMazeType: $selectedMazeType,
                        selectedAlgorithm: $selectedAlgorithm,
                        captureSteps: $captureSteps,
                        submitMazeRequest: {
                            submitMazeRequest()
                        }
                    )
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
            
            if isLoading {
//                Color.red.opacity(0.5)
//                        .ignoresSafeArea()
//                        .zIndex(2)
                LoadingOverlayView(
                    algorithm: selectedAlgorithm,
                    colorScheme: colorScheme,
                    fontScale: screenWidth > 700 ? 1.3 : 1.0
                )
                .zIndex(2)
            }
            
            if showCelebration {
              SparkleView(count: 60, totalDuration: 3.0)
                .zIndex(1)
                .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                    withAnimation { showCelebration = false }
                  }
                }
            }
            
        }
        .onAppear {
            // Remove the UserDefaults logic
            // let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            // if !hasLaunchedBefore {
            //     AudioServicesPlaySystemSound(1001)
            //     UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            // }
            
            if !didInitialRandomization {
                let types = MazeType.allCases.filter { $0 != .polar }
                selectedMazeType = types.randomElement()!
                let algos: [MazeAlgorithm]
                if selectedMazeType == .orthogonal {
                    algos = MazeAlgorithm.allCases
                } else {
                    algos = MazeAlgorithm.allCases
                        .filter { ![.binaryTree, .sidewinder].contains($0) }
                }
                selectedAlgorithm = algos.randomElement()!
                didInitialRandomization = true
            }
            
            ffi_integration_test_result = mazer_ffi_integration_test()
            print("mazer_ffi_integration_test returned: \(ffi_integration_test_result)")
            if ffi_integration_test_result == 42 {
                print("FFI integration test passed ✅")
            } else {
                print("FFI integration test failed ❌")
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // App has launched or come to the foreground
                if !hasPlayedSoundThisSession {
                    AudioServicesPlaySystemSound(1104)
                    hasPlayedSoundThisSession = true
                }
            case .background, .inactive:
                // App is going to background or is inactive; reset the flag for the next session
                hasPlayedSoundThisSession = false
            @unknown default:
                break
            }
        }
    }
    
    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    private func randomPaletteExcluding(current: HeatMapPalette, from allPalettes: [HeatMapPalette]) -> HeatMapPalette {
        let availablePalettes = allPalettes.filter { $0 != current }
        // If there’s at least one palette that isn’t the current, pick one at random.
        // Otherwise, fallback to returning the current palette.
        return availablePalettes.randomElement() ?? current
    }
    
    private func computeVerticalPadding() -> CGFloat {
        let screenH = UIScreen.main.bounds.height

        // 1) Your old “base” padding per maze type
        let basePadding: CGFloat = {
            switch selectedMazeType {
            case .delta:      return 230
            case .orthogonal: return 140
            case .sigma:      return 280
            case .polar:      return 0
            }
        }()

        // 2) A ratio by size to scale that down on small screens
        let sizeRatio: CGFloat = {
            switch selectedSize {
            case .small:  return 0.30   // 30% of screen height
            case .medium: return 0.25   // 25%
            case .large:  return 0.20   // 20%
            }
        }()

        // 3) Take the *minimum* of your old constant or the scaled value
        return min(basePadding, screenH * sizeRatio)
    }

    private func submitMazeRequest() {
        // Immediately set isLoading to true on the main thread
        DispatchQueue.main.async {
            self.isLoading = true
            print("isLoading set to true at: \(Date())") // For debugging
        }
        
        // Run maze generation on a background thread
        DispatchQueue.global().async {
            // Clean up any existing maze instance before creating a new one.
            if let current = self.currentGrid {
                mazer_destroy(current)
                self.currentGrid = nil
            }
            
            let adjustment: CGFloat = {
                switch self.selectedMazeType {
                case .delta:
                    switch self.selectedSize {
                    case .small: return 1.47
                    case .medium: return 1.55
                    case .large: return 1.7
                    }
                case .orthogonal:
                    switch self.selectedSize {
                    case .small:  return 1.4
                    case .medium: return 1.65
                    case .large:  return 1.9
                    }
                case .sigma:
                    switch self.selectedSize {
                    case .small:  return 0.75
                    case .medium: return 0.78
                    case .large:  return 0.82
                    }
                case .polar:
                    return 1.0
                }
            }()
            
            let rawSize = CGFloat(self.selectedSize.rawValue)
            let adjustedCellSize = adjustment * rawSize
            
            let screenH = UIScreen.main.bounds.height
            let isSmallDevice = screenH <= 667
            
            let perSidePad: CGFloat = {
                guard self.selectedMazeType != .orthogonal else { return 20 }
                return isSmallDevice ? 50 : 100
            }()
            
            let totalVerticalPadding = perSidePad * 2
            let controlArea: CGFloat = 80
            let availableH = screenH - controlArea - totalVerticalPadding
            let maxHeightRows = max(1, Int(availableH / adjustedCellSize))
            
            var finalHeight = (self.selectedMazeType == .sigma) ? maxHeightRows / 3 : maxHeightRows
            
            if self.selectedMazeType == .delta && UIDevice.current.userInterfaceIdiom == .pad {
                let maxRows = Int(availableH / adjustedCellSize * 0.77)
                finalHeight = min(finalHeight, maxRows)
            }
            
            let maxWidth = max(1, Int(UIScreen.main.bounds.width / adjustedCellSize))
            let finalWidth = (self.selectedMazeType == .sigma) ? maxWidth / 3 : maxWidth
            
            if self.captureSteps && (finalWidth > 100 || finalHeight > 100) {
                DispatchQueue.main.async {
                    self.errorMessage = "Show Maze Generation is only available for mazes with width and height ≤ 100."
                    self.isLoading = false
                }
                return
            }
            
            let result = MazeRequestValidator.validate(
                mazeType: self.selectedMazeType,
                width: finalWidth,
                height: finalHeight,
                algorithm: self.selectedAlgorithm,
                captureSteps: self.captureSteps
            )
            
            switch result {
            case .success(let jsonString):
                print("Valid JSON: \(jsonString)")
                
                guard let jsonCString = jsonString.cString(using: .utf8) else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid JSON encoding."
                        self.isLoading = false
                    }
                    return
                }
                
                guard let gridPtr = mazer_generate_maze(jsonCString) else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to generate maze."
                        self.isLoading = false
                    }
                    return
                }
                
                self.currentGrid = gridPtr
                
                var length: size_t = 0
                guard let cellsPtr = mazer_get_cells(gridPtr, &length) else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to retrieve cells."
                        self.isLoading = false
                    }
                    return
                }
                
                var cells: [MazeCell] = []
                for i in 0..<Int(length) {
                    let ffiCell = cellsPtr[i]
                    let mazeTypeCopy = ffiCell.maze_type != nil ? String(cString: ffiCell.maze_type!) : ""
                    let orientationCopy = ffiCell.orientation != nil ? String(cString: ffiCell.orientation!) : ""
                    
                    cells.append(MazeCell(
                        x: Int(ffiCell.x),
                        y: Int(ffiCell.y),
                        mazeType: mazeTypeCopy,
                        linked: self.convertCStringArray(ffiCell.linked, count: ffiCell.linked_len),
                        distance: Int(ffiCell.distance),
                        isStart: ffiCell.is_start,
                        isGoal: ffiCell.is_goal,
                        isActive: ffiCell.is_active,
                        isVisited: ffiCell.is_visited,
                        hasBeenVisited: ffiCell.has_been_visited,
                        onSolutionPath: ffiCell.on_solution_path,
                        orientation: orientationCopy
                    ))
                }
                
                mazer_free_cells(cellsPtr, length)
                
                var steps: [[MazeCell]] = []
                if self.captureSteps {
                    let stepsCount = mazer_get_generation_steps_count(gridPtr)
                    for i in 0..<stepsCount {
                        var stepLength: size_t = 0
                        guard let stepCellsPtr = mazer_get_generation_step_cells(gridPtr, i, &stepLength) else {
                            DispatchQueue.main.async {
                                self.errorMessage = "Failed to retrieve generation step cells."
                                self.isLoading = false
                            }
                            return
                        }
                        
                        var stepCells: [MazeCell] = []
                        for j in 0..<Int(stepLength) {
                            let ffiCell = stepCellsPtr[j]
                            let mazeTypeCopy = ffiCell.maze_type != nil ? String(cString: ffiCell.maze_type!) : ""
                            let orientationCopy = ffiCell.orientation != nil ? String(cString: ffiCell.orientation!) : ""
                            
                            stepCells.append(MazeCell(
                                x: Int(ffiCell.x),
                                y: Int(ffiCell.y),
                                mazeType: mazeTypeCopy,
                                linked: self.convertCStringArray(ffiCell.linked, count: ffiCell.linked_len),
                                distance: Int(ffiCell.distance),
                                isStart: ffiCell.is_start,
                                isGoal: ffiCell.is_goal,
                                isActive: ffiCell.is_active,
                                isVisited: ffiCell.is_visited,
                                hasBeenVisited: ffiCell.has_been_visited,
                                onSolutionPath: ffiCell.on_solution_path,
                                orientation: orientationCopy
                            ))
                        }
                        
                        steps.append(stepCells)
                        mazer_free_cells(stepCellsPtr, stepLength)
                    }
                }
                
                // Update UI on the main thread after generation
                DispatchQueue.main.async {
                    self.mazeCells = cells
                    if let firstCell = cells.first {
                        self.mazeType = MazeType(rawValue: firstCell.mazeType) ?? .orthogonal
                    }
                    if self.captureSteps {
                        self.generationSteps = steps
                        self.isAnimatingGeneration = true
                    } else {
                        self.mazeGenerated = true
                    }
                    self.isLoading = false
                    print("isLoading set to false at: \(Date())") // For debugging
                    self.errorMessage = nil
                    self.selectedPalette = self.randomPaletteExcluding(current: self.selectedPalette, from: allPalettes)
                    self.defaultBackgroundColor = self.randomDefaultExcluding(current: defaultBackgroundColor, from: defaultBackgroundColors)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "\(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func convertCStringArray(_ cArray: UnsafeMutablePointer<UnsafePointer<CChar>?>?, count: size_t) -> [String] {
        guard let cArray = cArray else { return [] }
        var result: [String] = []
        for i in 0..<Int(count) {
            if let cStr = cArray.advanced(by: i).pointee {
                result.append(String(cString: cStr))
            }
        }
        return result
    }
    
    private func celebrateVictory() {
        showCelebration = true

        // 1) Play a success haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)

        // 2) Play a system “success” sound (you can swap in your own asset if you like)
        AudioServicesPlaySystemSound(1001) // swoosh

        // 3) Tear down the animation after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showCelebration = false
            }
            showSolution = false // reset
            
//            // **new palette + new view-ID ↷ forces MazeRenderView to
//            // pick up the new palette and drop any “solution overlay”**
//            selectedPalette = randomPaletteExcluding(
//              current: selectedPalette,
//              from: allPalettes
//            )
//            defaultBackgroundColor = randomDefaultExcluding(
//                current: defaultBackgroundColor,
//                from: defaultBackgroundColors
//            )
            mazeID = UUID()
            submitMazeRequest() // generate a new maze with same settings upon maze completion
        }
    }
    
    private func performMove(direction: String) {
        if showCelebration {
            // don't move if maze has already been solved
            return;
        }
        
        // Ensure current grid exists.
        guard let gridPtr = currentGrid else { return }
        guard let directionCString = direction.cString(using: .utf8) else {
            errorMessage = "Encoding error for direction."
            return
        }
        
        // Prepare the haptic engine _before_ we even do the move
        haptic.prepare()

        // Convert the OpaquePointer to UnsafeMutableRawPointer using unsafeBitCast.
        let rawGridPtr = unsafeBitCast(gridPtr, to: UnsafeMutableRawPointer.self)
        
        // fallback list
        let tryDirections: [String] = {
            switch mazeType {
            case .orthogonal:
                return [direction]
                
            case .polar:
                return [direction]
                
            case .delta:
                // diagonal → straight
                switch direction {
                case "UpperRight": return ["UpperRight", "Right"]
                case "LowerRight": return ["LowerRight", "Right"]
                case "UpperLeft":  return ["UpperLeft",  "Left"]
                case "LowerLeft":  return ["LowerLeft",  "Left"]
                default:           return [direction]
                }
                
            case .sigma:
                // diagonal ↔ diagonal opposite
                switch direction {
                case "UpperRight": return ["UpperRight", "LowerRight"]
                case "LowerRight": return ["LowerRight", "UpperRight"]
                case "UpperLeft":  return ["UpperLeft",  "LowerLeft"]
                case "LowerLeft":  return ["LowerLeft",  "UpperLeft"]
                default:           return [direction]
                }
            }
        }()

        // Attempt each in turn
        var newGridRawPtr: UnsafeMutableRawPointer? = nil
        for dir in tryDirections {
            guard let dirCString = dir.cString(using: .utf8) else { continue }
            if let result = mazer_make_move(rawGridPtr, dirCString) {
                newGridRawPtr = result
                break
            }
        }
        
        guard let newGridRaw = newGridRawPtr else {
            return
        }
        
        AudioServicesPlaySystemSound(1104) // play a `click` sound on audio
        haptic.impactOccurred() // cause user to feel a `bump`
        
        // Convert the returned raw pointer to OpaquePointer.
        let newGrid: OpaquePointer = OpaquePointer(newGridRaw)
        currentGrid = newGrid

        var length: size_t = 0
        guard let cellsPtr = mazer_get_cells(newGrid, &length) else {
            errorMessage = "Failed to retrieve updated maze."
            return
        }
        
        var cells: [MazeCell] = []
        for i in 0..<Int(length) {
            let ffiCell = cellsPtr[i]
            let mazeTypeCopy = ffiCell.maze_type != nil ? String(cString: ffiCell.maze_type!) : ""
            let orientationCopy = ffiCell.orientation != nil ? String(cString: ffiCell.orientation!) : ""
            cells.append(MazeCell(
                x: Int(ffiCell.x),
                y: Int(ffiCell.y),
                mazeType: mazeTypeCopy,
                linked: convertCStringArray(ffiCell.linked, count: ffiCell.linked_len),
                distance: Int(ffiCell.distance),
                isStart: ffiCell.is_start,
                isGoal: ffiCell.is_goal,
                isActive: ffiCell.is_active,
                isVisited: ffiCell.is_visited,
                hasBeenVisited: ffiCell.has_been_visited,
                onSolutionPath: ffiCell.on_solution_path,
                orientation: orientationCopy
            ))
        }
        
        mazeCells = cells
        mazer_free_cells(cellsPtr, length)
        
        // If we just activated the goal, and haven't celebrated yet:
        if !showCelebration,
           mazeCells.contains(where: { $0.isGoal && $0.isActive }) {
            celebrateVictory()
        }
    }

}
