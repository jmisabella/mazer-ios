//
//  ContentView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 3/26/25.
//

import SwiftUI
import AudioToolbox
import UIKit

struct ContentView: View {
    @State private var ffi_integration_test_result: Int32 = 0
    @State private var mazeCells: [MazeCell] = []
    @State private var mazeType: MazeType = .orthogonal
    @State private var mazeGenerated: Bool = false
    @State private var errorMessage: String?

    @State private var selectedSize: CellSize = .large
    @State private var selectedMazeType: MazeType = .orthogonal
    @State private var selectedAlgorithm: MazeAlgorithm = .recursiveBacktracker
    @State private var showSolution: Bool = false
    @State private var showHeatMap: Bool = false
    @State private var showControls: Bool = false
    @State private var padOffset = CGSize(width: 0, height: 0)
    @State private var showCelebration: Bool = false
    @State private var selectedPalette: HeatMapPalette = allPalettes.randomElement()!
    @State private var mazeID = UUID()
    @State private var currentGrid: OpaquePointer? = nil
    @State private var defaultBackgroundColor: Color = CellColors.defaultBackgroundColors.randomElement()!
    @State private var didInitialRandomization = false
    @State private var hasPlayedSoundThisSession: Bool = false
    @State private var captureSteps: Bool = false
    @State private var isGeneratingMaze: Bool = false
    @State private var isAnimatingGeneration: Bool = false
    @State private var generationSteps: [[MazeCell]] = []
    @State private var isLoading: Bool = false
    @State private var optionalColor: Color? = nil
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    private func randomDefaultExcluding(current: Color, from all: [Color]) -> Color {
        let others = all.filter { $0 != current }
        return others.randomElement() ?? current
    }
    
    var body: some View {
        ZStack {
            backgroundView
            VStack {
                mainContentView()
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
            
            if isLoading {
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
            if let sizeRaw = UserDefaults.standard.object(forKey: "lastSize") as? Int,
               let size = CellSize(rawValue: sizeRaw),
               let mazeTypeRaw = UserDefaults.standard.string(forKey: "lastMazeType"),
               let mazeType = MazeType(rawValue: mazeTypeRaw),
               let algorithmRaw = UserDefaults.standard.string(forKey: "lastAlgorithm"),
               let algorithm = MazeAlgorithm(rawValue: algorithmRaw) {
                selectedSize = size
                selectedMazeType = mazeType
                selectedAlgorithm = algorithm
                showHeatMap = UserDefaults.standard.bool(forKey: "showHeatMap")
            } else {
                selectedMazeType = .orthogonal
                let algos: [MazeAlgorithm] = MazeAlgorithm.allCases
                selectedAlgorithm = algos.randomElement()!
                selectedSize = .medium
                showHeatMap = false
                
                UserDefaults.standard.set(selectedSize.rawValue, forKey: "lastSize")
                UserDefaults.standard.set(selectedMazeType.rawValue, forKey: "lastMazeType")
                UserDefaults.standard.set(selectedAlgorithm.rawValue, forKey: "lastAlgorithm")
                UserDefaults.standard.set(showHeatMap, forKey: "showHeatMap")
            }
            
            ffi_integration_test_result = mazer_ffi_integration_test()
            print("mazer_ffi_integration_test returned: \(ffi_integration_test_result)")
            if ffi_integration_test_result == 42 {
                print("FFI integration test passed ✅")
            } else {
                print("FFI integration test failed ❌")
            }
        }
        .onChange(of: selectedSize) {
            UserDefaults.standard.set(selectedSize.rawValue, forKey: "lastSize")
        }
        .onChange(of: selectedMazeType) {
            UserDefaults.standard.set(selectedMazeType.rawValue, forKey: "lastMazeType")
        }
        .onChange(of: selectedAlgorithm) {
            UserDefaults.standard.set(selectedAlgorithm.rawValue, forKey: "lastAlgorithm")
        }
        .onChange(of: showHeatMap) {
            UserDefaults.standard.set(showHeatMap, forKey: "showHeatMap")
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                if !hasPlayedSoundThisSession {
                    AudioServicesPlaySystemSound(1104)
                    hasPlayedSoundThisSession = true
                }
            case .background, .inactive:
                hasPlayedSoundThisSession = false
            @unknown default:
                break
            }
        }
    }
    
    private var backgroundView: some View {
        (colorScheme == .dark ? Color.black : CellColors.offWhite)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func mainContentView() -> some View {
        if isGeneratingMaze {
            ProgressView("Generating maze...")
        } else if isAnimatingGeneration {
            MazeGenerationAnimationView(
                generationSteps: generationSteps,
                mazeType: mazeType,
                cellSize: selectedSize,
                isAnimatingGeneration: $isAnimatingGeneration,
                mazeGenerated: $mazeGenerated,
                showSolution: $showSolution,
                showHeatMap: $showHeatMap,
                showControls: $showControls,
                selectedPalette: $selectedPalette,
                defaultBackground: $defaultBackgroundColor,
                mazeID: $mazeID,
                currentGrid: currentGrid,
                regenerateMaze: { submitMazeRequest() },
                cleanupMazeData: cleanupMazeData,
                cellSizes: computeCellSizes(mazeType: selectedMazeType, cellSize: selectedSize),
                optionalColor: optionalColor,
            )
        } else if mazeGenerated {
            mazeRenderView()
        } else {
            MazeRequestView(
                mazeCells: $mazeCells,
                mazeGenerated: $mazeGenerated,
                mazeType: $mazeType,
                selectedSize: $selectedSize,
                selectedMazeType: $selectedMazeType,
                selectedAlgorithm: $selectedAlgorithm,
                captureSteps: $captureSteps,
                submitMazeRequest: { submitMazeRequest() }
            )
        }
    }
    
    private func mazeRenderView() -> some View {
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
            cellSize: selectedSize,
            optionalColor: optionalColor,
            regenerateMaze: { submitMazeRequest() },
            moveAction: { direction in performMove(direction: direction) },
            cellSizes: computeCellSizes(mazeType: selectedMazeType, cellSize: selectedSize),
            toggleHeatMap: {
                showHeatMap.toggle()
                if showHeatMap {
                    selectedPalette = randomPaletteExcluding(current: selectedPalette, from: allPalettes)
                    defaultBackgroundColor = randomDefaultExcluding(current: defaultBackgroundColor, from: CellColors.defaultBackgroundColors)
                }
            },
            cleanupMazeData: cleanupMazeData
        )
//        .environment(\.colorScheme, .dark)
//        .padding(.vertical, 100)
        .padding(.vertical, computeVerticalPadding(mazeType: selectedMazeType, cellSize: selectedSize))
        .grayscale(showCelebration ? 1 : 0)
        .animation(.easeInOut(duration: 0.65), value: showCelebration)
    }
    
    private func cleanupMazeData() {
        if let gridPtr = currentGrid {
            mazer_destroy(gridPtr)
            currentGrid = nil
        }
        mazeCells = []
        generationSteps = []
        mazeGenerated = false
        isAnimatingGeneration = false
    }
    
    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    private func randomPaletteExcluding(current: HeatMapPalette, from allPalettes: [HeatMapPalette]) -> HeatMapPalette {
        let availablePalettes = allPalettes.filter { $0 != current }
        return availablePalettes.randomElement() ?? current
    }
    
    private func submitMazeRequest() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
        
        let insetTop = keyWindow?.safeAreaInsets.top    ?? 0
        let insetBot = keyWindow?.safeAreaInsets.bottom ?? 0
        
        DispatchQueue.global().async {
            if let current = self.currentGrid {
                mazer_destroy(current)
                self.currentGrid = nil
            }
            
            let (squareCellSize, octagonCellSize) = computeCellSizes(mazeType: selectedMazeType, cellSize: selectedSize)
            
            let screenH = UIScreen.main.bounds.height
            let isSmallDevice = screenH <= 667
            
//            let perSidePad: CGFloat = {
//                guard selectedMazeType != .orthogonal else { return 20 }
//                return isSmallDevice ? 50 : 100
//            }()
            
            let perSidePad: CGFloat = {
                switch selectedMazeType {
                case .orthogonal:
                    return 20
                case .upsilon:
//                    return isSmallDevice ? 18 : 35
                    return 12
                default:
                    return isSmallDevice ? 50 : 100
                }
            }()
            
            let totalVerticalPadding = perSidePad * 2
            let controlArea: CGFloat = 80
            let availableH = screenH - controlArea - totalVerticalPadding

            // account for notch & home-indicator
            let drawableH = availableH - insetTop - insetBot
            
            let cellSize = selectedMazeType == .upsilon ? octagonCellSize : squareCellSize
            let spacing = selectedMazeType == .upsilon ? (sqrt(2) / 2) * octagonCellSize : cellSize
            let rowHeight = selectedMazeType == .upsilon ? octagonCellSize * (sqrt(2) / 2) : cellSize
            
            let maxHeightRows = max(1, Int(availableH / (selectedMazeType == .upsilon ? rowHeight : cellSize)))
            let maxWidth = max(1, Int(UIScreen.main.bounds.width / spacing))
            
            var finalWidth: Int
            var finalHeight: Int
            
            if selectedMazeType == .rhombic {
                let s     = squareCellSize
                let diag  = s * CGFloat(2).squareRoot()
                let pitch = diag / 2
                finalWidth  = max(1, Int(floor(UIScreen.main.bounds.width  / diag)))
                finalHeight = max(1, Int(floor(drawableH / pitch)))
                
            } else {
                finalWidth = (selectedMazeType == .sigma) ? maxWidth / 3 : maxWidth
                finalHeight = (selectedMazeType == .sigma) ? maxHeightRows / 3 : maxHeightRows
            }
            
            if captureSteps && (finalWidth > 100 || finalHeight > 100) {
                DispatchQueue.main.async {
                    self.errorMessage = "Show Maze Generation is only available for mazes with width and height ≤ 100."
                    self.isLoading = false
                }
                return
            }
            
            let result = MazeRequestValidator.validate(
                mazeType: selectedMazeType,
                width: finalWidth,
                height: finalHeight,
                algorithm: selectedAlgorithm,
                captureSteps: captureSteps
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
                        linked: convertCStringArray(ffiCell.linked, count: ffiCell.linked_len),
                        distance: Int(ffiCell.distance),
                        isStart: ffiCell.is_start,
                        isGoal: ffiCell.is_goal,
                        isActive: ffiCell.is_active,
                        isVisited: ffiCell.is_visited,
                        hasBeenVisited: ffiCell.has_been_visited,
                        onSolutionPath: ffiCell.on_solution_path,
                        orientation: orientationCopy,
                        isSquare: ffiCell.is_square
                    ))
                }
                
                mazer_free_cells(cellsPtr, length)
                
                var steps: [[MazeCell]] = []
                if captureSteps {
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
                                linked: convertCStringArray(ffiCell.linked, count: ffiCell.linked_len),
                                distance: Int(ffiCell.distance),
                                isStart: ffiCell.is_start,
                                isGoal: ffiCell.is_goal,
                                isActive: ffiCell.is_active,
                                isVisited: ffiCell.is_visited,
                                hasBeenVisited: ffiCell.has_been_visited,
                                onSolutionPath: ffiCell.on_solution_path,
                                orientation: orientationCopy,
                                isSquare: ffiCell.is_square
                            ))
                        }
                        
                        steps.append(stepCells)
                        mazer_free_cells(stepCellsPtr, stepLength)
                    }
                }
                
                DispatchQueue.main.async {
                    self.mazeCells = cells
                    if let firstCell = cells.first {
                        self.mazeType = MazeType.fromFFIName(firstCell.mazeType) ?? .orthogonal
                    } else {
                        self.mazeType = .orthogonal
                        print("Warning: Could not determine maze type from cells.")
                    }
                    if self.captureSteps {
                        self.generationSteps = steps
                        self.isAnimatingGeneration = true
                    } else {
                        self.mazeGenerated = true
                    }
                    let defaultColors: [Color] = [.pink, .gray, .yellow, .blue, .purple, .orange]
                    var optionalColor: Color? = nil
                    if Bool.random() {
                        optionalColor = defaultColors.randomElement()
                    }
                    self.optionalColor = optionalColor
                    self.isLoading = false
                    self.errorMessage = nil
                    self.selectedPalette = self.randomPaletteExcluding(current: self.selectedPalette, from: allPalettes)
                    self.defaultBackgroundColor = self.randomDefaultExcluding(current: defaultBackgroundColor, from: CellColors.defaultBackgroundColors)
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
        captureSteps = false

        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
        
        AudioServicesPlaySystemSound(1001)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showCelebration = false
            }
            showSolution = false
            mazeID = UUID()
            submitMazeRequest()
        }
    }
    
    private func performMove(direction: String) {
        if showCelebration {
            return
        }
        
        guard let gridPtr = currentGrid else { return }
        
        haptic.prepare()
        
        let rawGridPtr = unsafeBitCast(gridPtr, to: UnsafeMutableRawPointer.self)
        
        let tryDirections: [String] = {
            switch mazeType {
            case .orthogonal: return [direction]
            case .delta:
                switch direction {
                case "UpperRight": return ["UpperRight", "Right"]
                case "LowerRight": return ["LowerRight", "Right"]
                case "UpperLeft": return ["UpperLeft", "Left"]
                case "LowerLeft": return ["LowerLeft", "Left"]
                default: return [direction]
                }
            case .sigma:
                switch direction {
                case "UpperRight": return ["UpperRight", "LowerRight"]
                case "LowerRight": return ["LowerRight", "UpperRight"]
                case "UpperLeft": return ["UpperLeft", "LowerLeft"]
                case "LowerLeft": return ["LowerLeft", "UpperLeft"]
                default: return [direction]
                }
            case .upsilon: return [direction]
            case .rhombic: return [direction]
            }
        }()
        
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
        
        AudioServicesPlaySystemSound(1104)
        haptic.impactOccurred()
        
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
                orientation: orientationCopy,
                isSquare: ffiCell.is_square
            ))
        }
        
        mazeCells = cells
        mazer_free_cells(cellsPtr, length)
        
        if !showCelebration,
           mazeCells.contains(where: { $0.isGoal && $0.isActive }) {
            celebrateVictory()
        }
    }
}
