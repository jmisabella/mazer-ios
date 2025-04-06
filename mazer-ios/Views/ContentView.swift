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
    // user selections from request view
    @State private var selectedSize: MazeSize = .small
    @State private var selectedMazeType: MazeType = .orthogonal
    @State private var selectedAlgorithm: MazeAlgorithm = .recursiveBacktracker
    // user selections from render view
    @State private var showSolution: Bool = false
    @State private var showHeatMap: Bool = false
    
//    @State private var startX: Int = {
//        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
//        return maxWidth / 2 - 1
//    }()
//    
//    @State private var startY: Int = 0
//    
//    @State private var goalX: Int = {
//        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
//        return maxWidth / 2 - 1
//    }()
//    
//    @State private var goalY: Int = {
//        let maxHeight = max(1, Int((UIScreen.main.bounds.height - 200) / 9))
//        return maxHeight - 1
//    }()
    
    @State private var startX: Int = {
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
        return maxWidth / 2 - 1
    }()

    @State private var startY: Int = {
        let maxHeight = max(1, Int((UIScreen.main.bounds.height - 200) / 9))
        return maxHeight - 1 // 👈 bottom row
    }()

    @State private var goalX: Int = {
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
        return maxWidth / 2 - 1
    }()

    @State private var goalY: Int = 0 // 👈 top row

    
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
                        // Just call the request function again
                        submitMazeRequest()  // You may need to pull this up into ContentView if it isn't already
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
            
            // Optionally display any error messages
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            ffi_integration_test_result = mazer_ffi_integration_test()
            print("mazer_ffi_integration_test returned: \(ffi_integration_test_result)")
            
            // Verify result is 42
            if ffi_integration_test_result == 42 {
                print("FFI integration test passed ✅")
            } else {
                print("FFI integration test failed ❌")
            }
        }
    }
    
    private func submitMazeRequest() {
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
            var length: size_t = 0
            
            if let mazePointer = mazer_generate_maze(jsonCString, &length) {
                print("Maze generated with length: \(length)")
                
                var cells: [MazeCell] = []
                for i in 0..<Int(length) {
                    let cell = mazePointer[i]
                    let mazeTypeCopy = cell.maze_type != nil ? String(cString: cell.maze_type!) : ""
                    let orientationCopy = cell.orientation != nil ? String(cString: cell.orientation!) : ""
                    
                    cells.append(MazeCell(
                        x: Int(cell.x),
                        y: Int(cell.y),
                        mazeType: mazeTypeCopy,
                        linked: convertCStringArray(cell.linked, count: cell.linked_len),
                        distance: Int(cell.distance),
                        isStart: cell.is_start,
                        isGoal: cell.is_goal,
                        isVisited: cell.is_visited,
                        onSolutionPath: cell.on_solution_path,
                        orientation: orientationCopy
                    ))
                }

                mazeCells = cells
                mazer_free_cells(mazePointer, length)

                if let firstCell = cells.first {
                    mazeType = MazeType(rawValue: firstCell.mazeType) ?? .orthogonal
                }

                mazeGenerated = true
                errorMessage = nil
            } else {
                errorMessage = "Failed to generate maze."
            }
            
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


