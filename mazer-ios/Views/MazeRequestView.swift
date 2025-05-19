import SwiftUI

struct MazeRequestView: View {
    
    @Binding var mazeCells: [MazeCell]
    @Binding var mazeGenerated: Bool
    @Binding var mazeType: MazeType 
    @Binding var selectedSize: MazeSize
    @Binding var selectedMazeType: MazeType
    @Binding var selectedAlgorithm: MazeAlgorithm
    
    let submitMazeRequest: () -> Void
    
    @State private var errorMessage: String? = nil
    
    
    private let horizontalMargin = 10 // TODO: this number must match hard-coded offsets in ContentView! Must couple these 2 variables to address this
    private let verticalMargin = 280 // TODO: this number must match hard-coded offsets in ContentView! Must couple these 2 variables to address this
    
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
    
    private var availableAlgorithms: [MazeAlgorithm] {
        if selectedMazeType == .orthogonal {
            return MazeAlgorithm.allCases
        } else {
            return MazeAlgorithm.allCases
                .filter { ![.binaryTree, .sidewinder].contains($0) }
        }
    }
    
    private func randomizeAlgorithm() {
        if let algo = availableAlgorithms.randomElement() {
            selectedAlgorithm = algo
        }
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Maze Quest")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Omni Mazes & Solutions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                Picker("Maze Size", selection: $selectedSize) {
                    ForEach(MazeSize.allCases) { size in
                        Text(size.label).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Maze Type", selection: $selectedMazeType) {
                    // ignore .polar for now, sinze it's not yet implemented
                    ForEach(MazeType.allCases.filter { $0 != .polar }) { type in
                        Text(type.rawValue.capitalized)
                            .tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedMazeType) { _ in
                    randomizeAlgorithm()
                    // if the old algorithm isn't in the new list, pick the first valid one
                    if !availableAlgorithms.contains(selectedAlgorithm),
                       let firstValid = availableAlgorithms.first
                    {
                        selectedAlgorithm = firstValid
                    }
                }
                
                // Display the selected maze type description.
                Text(selectedMazeType.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Picker("Algorithm", selection: $selectedAlgorithm) {
                    ForEach(availableAlgorithms) { algo in
                        Text(algo.rawValue)
                            .tag(algo)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                // Display the selected algorithm's description.
                Text(selectedAlgorithm.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

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
    

}



