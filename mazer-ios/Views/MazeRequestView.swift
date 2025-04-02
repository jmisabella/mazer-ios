import SwiftUI

struct MazeRequestView: View {
    
    @Binding var mazeCells: [MazeCell]
    @State private var errorMessage: String? = nil
    @State private var selectedSize: MazeSize = .medium
    @State private var selectedMazeType: MazeType = .orthogonal
    @State private var selectedAlgorithm: MazeAlgorithm = .recursiveBacktracker
    
    @State private var startX: Int = {
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
        return maxWidth / 2
    }()

    @State private var startY: Int = 0

    @State private var goalX: Int = {
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / 9))
        return maxWidth / 2
    }()

    @State private var goalY: Int = {
        let maxHeight = max(1, Int((UIScreen.main.bounds.height - 200) / 9))
        return maxHeight
    }()
    
    @FocusState private var focusedField: Field?

    private enum MazeSize: Int, CaseIterable, Identifiable {
        case small = 6, medium = 9, large = 15
        var id: Int { rawValue }
        var label: String {
            switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
            }
        }
    }
    
    private enum Field {
        case startX, startY, goalX, goalY
    }
    
    private let horizontalMargin = 40 // TODO: adjust as necessary
    private let verticalMargin = 200 // TODO: adjust as necessary
    
    private var maxWidth: Int {
        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
    }

    private var maxHeight: Int {
        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
    }
    
    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
    
    private var availableWidth: CGFloat {
        screenWidth - CGFloat(horizontalMargin) // Adjust for margins, paddings
    }
    
    private var availableHeight: CGFloat {
        screenHeight - CGFloat(verticalMargin) // Adjust for nav bar, controls, etc.
    }
    
    private var mazeWidth: Int {
        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
    }
    
    private var mazeHeight: Int {
        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            
            VStack(spacing: 20) {
                Picker("Maze Size", selection: $selectedSize) {
                    ForEach(MazeSize.allCases) { size in
                        Text(size.label).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedSize) { _, _ in
                    updateStartAndGoalPositions()
                }

                Picker("Maze Type", selection: $selectedMazeType) {
                    ForEach(MazeType.allCases) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("Algorithm", selection: $selectedAlgorithm) {
                    ForEach(MazeAlgorithm.allCases) { algo in
                        Text(algo.rawValue).tag(algo)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                VStack {
                    HStack {
                        TextField("Start X", text: Binding(
                            get: { String(startX) },
                            set: { startX = Int(filterAndClampWidthInput($0, max: maxWidth)) ?? 0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .startX)

                        TextField("Start Y", text: Binding(
                            get: { String(startY) },
                            set: { startY = Int(filterAndClampHeightInput($0, max: maxHeight, defaultHeight: 0)) ?? 0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .startY)
                    }

                    HStack {
                        TextField("Goal X", text: Binding(
                            get: { String(goalX) },
                            set: { goalX = Int(filterAndClampWidthInput($0, max: maxWidth)) ?? 0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .goalX)

                        TextField("Goal Y", text: Binding(
                            get: { String(goalY) },
                            set: { goalY = Int(filterAndClampHeightInput($0, max: maxHeight, defaultHeight: maxHeight)) ?? 0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .goalY)
                    }
                }

                Button("Generate Maze") {
                    submitMazeRequest()
                }
                .buttonStyle(.borderedProminent)
                .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Divider()

                Text("Maze Width: \(mazeWidth), Maze Height: \(mazeHeight)")
                    .padding()
            }
            .padding()
        }
    }

    
    private func filterAndClampWidthInput(_ value: String, max: Int) -> String {
        if let intValue = Int(value), intValue >= 0 && intValue <= max {
            return String(intValue)  // Convert the valid int value back to a string
        }
        return String(max)
    }
    
    private func filterAndClampHeightInput(_ value: String, max: Int, defaultHeight: Int) -> String {
        if let intValue = Int(value), intValue >= 0 && intValue <= max {
            return String(intValue)  // Convert the valid int value back to a string
        }
        return String(defaultHeight)
    }
    
    // Function to update Start and Goal X/Y positions when Maze Size changes
    private func updateStartAndGoalPositions() {
        startX = max(1, Int(availableWidth / CGFloat(selectedSize.rawValue))) / 2
        goalX = startX
        startY = 0
        goalY = max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
    }

    private func submitMazeRequest() {
        focusedField = nil  // Dismiss keyboard

        let result = MazeRequestValidator.validate(
            mazeType: selectedMazeType,
            width: mazeWidth,
            height: mazeHeight,
            algorithm: selectedAlgorithm,
            start_x: startX,
            start_y: startY,
            goal_x: goalX,
            goal_y: goalY
        )

        switch result {
        case .success(let jsonString):
            print("Valid JSON: \(jsonString)")

            let jsonCString = jsonString.cString(using: .utf8)
            var length: size_t = 0

            if let mazePointer = mazer_generate_maze(jsonCString, &length) {
                print("Maze generated with length: \(length)")

                let buffer = UnsafeBufferPointer(start: mazePointer, count: Int(length))
                mazeCells = buffer.map { cell in
                    MazeCell(
                        x: Int(cell.x),
                        y: Int(cell.y),
                        mazeType: String(cString: cell.maze_type),
                        linked: convertCStringArray(cell.linked),
                        distance: Int(cell.distance),
                        isStart: cell.is_start,
                        isGoal: cell.is_goal,
                        onSolutionPath: cell.on_solution_path,
                        orientation: String(cString: cell.orientation)
                    )
                }

                // Free memory after conversion
                mazer_free_cells(mazePointer, length)
                errorMessage = nil  // Clear any previous error

            } else {
                errorMessage = "Failed to generate maze."
            }

        case .failure(let error):
            errorMessage = "\(error.localizedDescription)"
        }
    }

    
    private func convertCStringArray(_ cArray: UnsafeMutablePointer<UnsafePointer<CChar>?>?) -> [String] {
        var result: [String] = []
        
        guard let cArray = cArray else { return result }
        
        var index = 0
        while let cStr = cArray.advanced(by: index).pointee, cStr != nil {
            result.append(String(cString: cStr))
            index += 1
        }

        return result
    }

}

struct MazeRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MazeRequestView(mazeCells: .constant([])) // pass empty array for preview
    }
}

