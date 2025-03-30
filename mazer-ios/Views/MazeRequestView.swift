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
    
    @State private var startX: String = ""
    @State private var startY: String = ""
    @State private var goalX: String = ""
    @State private var goalY: String = ""
    
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
                TextField("Start X", text: $startX)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: startX) { startX = filterAndClampInput(startX, max: maxWidth) }
                TextField("Start Y", text: $startY)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: startY) { startY = filterAndClampInput(startY, max: maxHeight) }
            }
            
            HStack {
                TextField("Goal X", text: $goalX)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: goalX) { goalX = filterAndClampInput(goalX, max: maxWidth) }
                TextField("Goal Y", text: $goalY)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: goalY) { goalY = filterAndClampInput(goalY, max: maxHeight) }
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
    }
}

struct MazeRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MazeRequestView()
    }
}

