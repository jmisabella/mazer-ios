//
//  ContentView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 3/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var ffi_integration_test_result: Int32 = 0
    @State private var mazeCells: [MazeCell] = []
    @State private var mazeType: MazeType = .orthogonal
    @State private var mazeGenerated: Bool = false
    @State private var errorMessage: String?

    // User selections from request view
    @State private var selectedSize: MazeSize = .small
    @State private var selectedMazeType: MazeType = .orthogonal
    @State private var selectedAlgorithm: MazeAlgorithm = .recursiveBacktracker
    // User selections from render view
    @State private var showSolution: Bool = false
    @State private var showHeatMap: Bool = false

    @State private var startX: Int = {
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
        return maxWidth / 2 - 1
    }()
    @State private var startY: Int = {
        let maxHeight = max(1, Int((UIScreen.main.bounds.height - 200) / 9))
        return maxHeight - 1 // bottom row
    }()
    @State private var goalX: Int = {
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
        return maxWidth / 2 - 1
    }()
    @State private var goalY: Int = 0 // top row

    // Track the opaque maze pointer.
    @State private var currentGrid: OpaquePointer? = nil

    var body: some View {
        VStack {
            if mazeGenerated {
                MazeRenderView(
                    mazeGenerated: $mazeGenerated,
                    showSolution: $showSolution,
                    showHeatMap: $showHeatMap,
                    mazeCells: mazeCells,
                    mazeType: mazeType,
                    regenerateMaze: {
                        submitMazeRequest()
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
                    startX: $startX,
                    startY: $startY,
                    goalX: $goalX,
                    goalY: $goalY,
                    submitMazeRequest: submitMazeRequest
                )
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            ffi_integration_test_result = mazer_ffi_integration_test()
            print("mazer_ffi_integration_test returned: \(ffi_integration_test_result)")
            if ffi_integration_test_result == 42 {
                print("FFI integration test passed ✅")
            } else {
                print("FFI integration test failed ❌")
            }
        }
    }
    
    private func submitMazeRequest() {
        // Clean up any existing maze instance before creating a new one.
        if let current = currentGrid {
            // Directly pass the opaque pointer to mazer_destroy.
            mazer_destroy(current)
            currentGrid = nil
        }
        
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / CGFloat(selectedSize.rawValue)))
        let maxHeight = max(1, Int((UIScreen.main.bounds.height - 200) / CGFloat(selectedSize.rawValue)))
        
        let result = MazeRequestValidator.validate(
            mazeType: selectedMazeType,
            width: maxWidth,
            height: maxHeight,
            algorithm: selectedAlgorithm,
            start_x: startX,
            start_y: startY,
            goal_x: goalX,
            goal_y: goalY
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
                    isVisited: ffiCell.is_visited,
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
}
