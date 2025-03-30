import SwiftUI

struct MazeRequestView: View {
    
    enum MazeSize: Int, CaseIterable, Identifiable {
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

    
    let horizontalMargin = 40 // TODO: adjust as necessary
    let verticalMargin = 200 // TODO: adjust as necessary
    
    var maxWidth: Int {
        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
    }

    var maxHeight: Int {
        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
    }
    
    var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    var screenHeight: CGFloat { UIScreen.main.bounds.height }
    
    var availableWidth: CGFloat {
        screenWidth - CGFloat(horizontalMargin) // Adjust for margins, paddings
    }
    
    var availableHeight: CGFloat {
        screenHeight - CGFloat(verticalMargin) // Adjust for nav bar, controls, etc.
    }
    
    var mazeWidth: Int {
        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
    }
    
    var mazeHeight: Int {
        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Maze Size", selection: $selectedSize) {
                ForEach(MazeSize.allCases) { size in
                    Text(size.label).tag(size)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedSize) { _ in
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

            // Start X and Y
            HStack {
                TextField("Start X", text: Binding(
                    get: { String(startX) },
                    set: { startX = Int(filterAndClampWidthInput($0, max: maxWidth)) ?? 0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

                TextField("Start Y", text: Binding(
                    get: { String(startY) },
                    set: { startY = Int(filterAndClampHeightInput($0, max: maxHeight, defaultHeight: 0)) ?? 0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            }

            // Goal X and Y
            HStack {
                TextField("Goal X", text: Binding(
                    get: { String(goalX) },
                    set: { goalX = Int(filterAndClampWidthInput($0, max: maxWidth)) ?? 0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

                TextField("Goal Y", text: Binding(
                    get: { String(goalY) },
                    set: { goalY = Int(filterAndClampHeightInput($0, max: maxHeight, defaultHeight: maxHeight)) ?? 0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            }

            Button("Generate Maze") {
                submitMazeRequest()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Divider()

            Text("Maze Width: \(mazeWidth), Maze Height: \(mazeHeight)")
                .padding()
        }
        .padding()
    }
    
    func filterAndClampWidthInput(_ value: String, max: Int) -> String {
        if let intValue = Int(value), intValue >= 0 && intValue <= max {
            return String(intValue)  // Convert the valid int value back to a string
        }
        return String(max / 2)
    }
    
    func filterAndClampHeightInput(_ value: String, max: Int, defaultHeight: Int) -> String {
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

    func submitMazeRequest() {
        // validate input and generate JSON request
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
        
        // Handling the result
        switch result {
        case .success(let jsonString):
            print("Valid JSON: \(jsonString)")
            
            // Prepare to call the FFI function
            let jsonCString = jsonString.cString(using: .utf8)  // Convert Swift String to C String
            var length: size_t = 0  // Initialize length variable
            
            // Call the C function through FFI
            if let mazePointer = mazer_generate_maze(jsonCString, &length) {
                // Successfully got maze, process it here
                print("Maze generated with length: \(length)")
                // Further processing of mazePointer...
            } else {
                print("Error: Failed to generate maze")
            }
            
        case .failure(let error):
            print("Validation failed: \(error.localizedDescription)")
        }
    }
}

struct MazeRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MazeRequestView()
    }
}

