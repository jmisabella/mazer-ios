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
    
    @State private var startX: Int = 0
    @State private var startY: Int = 0
    @State private var goalX: Int = 0
    @State private var goalY: Int = 0
    
    var maxWidth: Int {
        // Placeholder calculation, will adjust based on screen size
        return 50 / selectedSize.rawValue
    }
    var maxHeight: Int {
        return 80 / selectedSize.rawValue
    }
    
    var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    var screenHeight: CGFloat { UIScreen.main.bounds.height }
    
    var availableWidth: CGFloat {
        screenWidth - 40 // Adjust for margins, paddings
    }
    
    var availableHeight: CGFloat {
        screenHeight - 200 // Adjust for nav bar, controls, etc.
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
            
            HStack {
                TextField("Start X", text: Binding(
                    get: { String(startX) },
                    set: { newValue in
                        if let intValue = Int(newValue) {
                            startX = min(max(intValue, 0), maxWidth) // Clamp to valid range
                        }
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

                TextField("Start Y", text: Binding(
                    get: { String(startY) },
                    set: { newValue in
                        if let intValue = Int(newValue) {
                            startY = min(max(intValue, 0), maxHeight) // Clamp to valid range
                        }
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            }

            
            HStack {
                TextField("Goal X", text: Binding(
                    get: { String(goalX) },
                    set: { newValue in
                        if let intValue = Int(newValue) {
                            goalX = min(max(intValue, 0), maxWidth) // Clamp to valid range
                        }
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

                TextField("Goal Y", text: Binding(
                    get: { String(goalY) },
                    set: { newValue in
                        if let intValue = Int(newValue) {
                            goalY = min(max(intValue, 0), maxHeight) // Clamp to valid range
                        }
                    }
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
    
    func filterAndClampInput(_ input: String, max: Int) -> String {
        let filtered = input.filter { $0.isNumber }
        if let intValue = Int(filtered), intValue <= max {
            return String(intValue)
        }
        return filtered.isEmpty ? "" : String(max)
    }
    
    func submitMazeRequest() {
        // TODO: Validate input and generate JSON request
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

