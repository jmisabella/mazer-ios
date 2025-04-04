import SwiftUI

struct MazeRequestView: View {
    
    @Binding var mazeCells: [MazeCell]
    @Binding var mazeGenerated: Bool
    @Binding var mazeType: MazeType 
    @Binding var selectedSize: MazeSize
    @Binding var selectedMazeType: MazeType
    @Binding var selectedAlgorithm: MazeAlgorithm
        
    @Binding var startX: Int
    @Binding var startY: Int
    @Binding var goalX: Int
    @Binding var goalY: Int
    
    let submitMazeRequest: () -> Void
    
    @State private var errorMessage: String? = nil
    
    @FocusState private var focusedField: Field?
    
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
                    focusedField = nil
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
        return String(max - 1)
    }
    
    private func filterAndClampHeightInput(_ value: String, max: Int, defaultHeight: Int) -> String {
        if let intValue = Int(value), intValue >= 0 && intValue <= max {
            return String(intValue)  // Convert the valid int value back to a string
        }
        return String(defaultHeight)
    }
    
    // Function to update Start and Goal X/Y positions when Maze Size changes
//    private func updateStartAndGoalPositions() {
//        startX = (max(1, Int(availableWidth / CGFloat(selectedSize.rawValue))) / 2) - 1
//        goalX = startX  // Same adjustment for goalX
//        startY = 0  // No change here, it's already zero-based
//        goalY = max(1, Int(availableHeight / CGFloat(selectedSize.rawValue))) - 1
//    }
    // Function to update Start and Goal X/Y positions when Maze Size changes
    private func updateStartAndGoalPositions() {
        let maxWidth = max(1, Int((UIScreen.main.bounds.width - 40) / CGFloat(selectedSize.rawValue)))
        let maxHeight = max(1, Int((UIScreen.main.bounds.height - 200) / CGFloat(selectedSize.rawValue)))

        startX = maxWidth / 2 - 1
        goalX = startX
        startY = maxHeight - 1 // 👈 bottom
        goalY = 0              // 👈 top
    }



}

struct MazeRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MazeRequestView(
            mazeCells: .constant([]),
            mazeGenerated: .constant(false),
            mazeType: .constant(.orthogonal),
            selectedSize: .constant(.medium),
            selectedMazeType: .constant(.orthogonal),
            selectedAlgorithm: .constant(.recursiveBacktracker),
            startX: .constant(0),
            startY: .constant(0),
            goalX: .constant(1),
            goalY: .constant(1),
            submitMazeRequest: {
                print("Preview Maze Request Triggered")
            }
        )
    }
}

