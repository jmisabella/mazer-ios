//
//  ContentView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 3/26/25.
//

import SwiftUI
import AudioToolbox
import UIKit  // for UIFeedbackGenerator

// GridQuest: Omni Mazes & Solver

struct ContentView: View {
    @State private var ffi_integration_test_result: Int32 = 0
    @State private var mazeCells: [MazeCell] = []
    @State private var mazeType: MazeType = .orthogonal
    @State private var mazeGenerated: Bool = false
    @State private var errorMessage: String?

    // User selections from request view
    @State private var selectedSize: MazeSize = .medium
    @State private var selectedMazeType: MazeType = .orthogonal
    @State private var selectedAlgorithm: MazeAlgorithm = .recursiveBacktracker
    // User selections from render view
    @State private var showSolution: Bool = false
    @State private var showHeatMap: Bool = false
    @State private var showControls: Bool = false
    // track the arrow‐pad’s drag offset
    @State private var padOffset = CGSize(width: 0, height: 0)
    @State private var showCelebration: Bool = false
    

    // Track the opaque maze pointer.
    @State private var currentGrid: OpaquePointer? = nil
    
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            VStack {
                if mazeGenerated {
                    MazeRenderView(
                        mazeGenerated: $mazeGenerated,
                        showSolution: $showSolution,
                        showHeatMap: $showHeatMap,
                        showControls: $showControls,
                        padOffset: $padOffset,
                        mazeCells: mazeCells,
                        mazeType: mazeType,
                        regenerateMaze: {
                            submitMazeRequest()
                        },
                        moveAction: { direction in
                            performMove(direction: direction)
                        }
                    )
                } else {
                    MazeRequestView(
                        mazeCells: $mazeCells,
                        mazeGenerated: $mazeGenerated,
                        mazeType: $mazeType,
                        selectedSize: $selectedSize,
                        selectedMazeType: $selectedMazeType,
                        selectedAlgorithm: $selectedAlgorithm,
                        submitMazeRequest: submitMazeRequest
                    )
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .onAppear {
            ffi_integration_test_result = mazer_ffi_integration_test()
            print("mazer_ffi_integration_test returned: \(ffi_integration_test_result)")
            if ffi_integration_test_result == 42 {
                print("FFI integration test passed ✅")
            } else {
                print("FFI integration test failed ❌")
            }
        }
        
        if showCelebration {
              ConfettiView()
                .ignoresSafeArea()
                .transition(.opacity)
            }
    }
    
    private func submitMazeRequest() {
        // Clean up any existing maze instance before creating a new one.
        if let current = currentGrid {
            // Directly pass the opaque pointer to mazer_destroy.
            mazer_destroy(current)
            currentGrid = nil
        }
        
        var adjustment = 1.0
        var verticalPadding = 0.0
        
        
        if selectedMazeType == .delta {
            adjustment = 0.85
            if selectedSize == .medium {
                adjustment = 0.97
            } else if selectedSize == .large {
                adjustment = 1.15
            }
            verticalPadding = CGFloat(280)
            
        } else if selectedMazeType == .orthogonal {
            adjustment = 0.92
            if selectedSize == .medium {
                adjustment = 1.1
            } else if selectedSize == .large {
                adjustment = 1.2
            }
            verticalPadding = CGFloat(280)
        } else if selectedMazeType == .sigma {
            adjustment = 0.72
            if selectedSize == .medium {
                adjustment = 0.8
            } else if selectedSize == .large {
                adjustment = 1.0
            }
            verticalPadding = CGFloat(280)
        }
        
        let adjustedCellSize = adjustment * CGFloat(selectedSize.rawValue)
        var maxWidth = max(1, Int((UIScreen.main.bounds.width) / adjustedCellSize))
        var maxHeight = max(1, Int((UIScreen.main.bounds.height - verticalPadding) / adjustedCellSize))
        
        if selectedMazeType == .sigma {
            maxWidth = maxWidth / 3
            maxHeight = maxHeight / 3
        }
        
//        
        let result = MazeRequestValidator.validate(
            mazeType: selectedMazeType,
            width: maxWidth,
            height: maxHeight,
            algorithm: selectedAlgorithm
        )
        
        switch result {
        case .success(let jsonString):
            print("Valid JSON: \(jsonString)")
            
            guard let jsonCString = jsonString.cString(using: .utf8) else {
                errorMessage = "Invalid JSON encoding."
                return
            }
            
            // Call the FFI function to generate a maze.
            guard let gridPtr = mazer_generate_maze(jsonCString) else {
                errorMessage = "Failed to generate maze."
                return
            }
            
            // Save the grid pointer directly.
            currentGrid = gridPtr
            
            var length: size_t = 0
            // mazer_get_cells returns an UnsafeMutablePointer<FFICell>, so no extra cast is needed.
            guard let cellsPtr = mazer_get_cells(gridPtr, &length) else {
                errorMessage = "Failed to retrieve cells."
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
            if let firstCell = cells.first {
                mazeType = MazeType(rawValue: firstCell.mazeType) ?? .orthogonal
            }
            
            // Free the cells array allocated on the Rust side.
            mazer_free_cells(cellsPtr, length)
            
            mazeGenerated = true
            errorMessage = nil
            
        case .failure(let error):
            errorMessage = "\(error.localizedDescription)"
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
            withAnimation { showCelebration = false }
        }
    }
    
    private func performMove(direction: String) {
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

        guard let newGridRaw = mazer_make_move(rawGridPtr, directionCString) else {
            // don't display any msg, simply return, if attempted move didn't succeed
            return
        }
        
        // play `click` sound on audio
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
