import SwiftUI

struct MazeRequestView: View {
    
    @Binding var mazeCells: [MazeCell]
    @Binding var mazeGenerated: Bool
    @Binding var mazeType: MazeType
    @Binding var selectedSize: CellSize
    @Binding var selectedMazeType: MazeType
    @Binding var selectedAlgorithm: MazeAlgorithm
    @Binding var captureSteps: Bool
    
    let submitMazeRequest: () -> Void
    
    @State private var errorMessage: String? = nil
    @State private var didRandomizeOnAppear = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let horizontalMargin = 10
    private let verticalMargin = 280
    
    private var maxWidth: Int {
        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
    }

    private var maxHeight: Int {
        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
    }
    
    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
    
    private var availableWidth: CGFloat {
        screenWidth - CGFloat(horizontalMargin)
    }
    
    private var availableHeight: CGFloat {
        screenHeight - CGFloat(verticalMargin)
    }
    
    private var mazeWidth: Int {
        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
    }
    
    private var mazeHeight: Int {
        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
    }
    
    private var fontScale: CGFloat {
        screenWidth > 700 ? 1.3 : 1.0
    }
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var availableAlgorithms: [MazeAlgorithm] {
        if selectedMazeType == .orthogonal {
            return MazeAlgorithm.allCases
        } else {
            return MazeAlgorithm.allCases
                .filter { ![.binaryTree, .sidewinder, .ellers, .recursiveDivision].contains($0) }
        }
    }
        
    private func randomizeType() {
        let types = MazeType.allCases.filter { $0 != .polar }
        if let randomType = types.randomElement() {
            selectedMazeType = randomType
        }
    }
        
    private func randomizeAlgorithm() {
        if let algo = availableAlgorithms.randomElement() {
            selectedAlgorithm = algo
        }
    }
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.offWhite)
                .ignoresSafeArea()
                .contentShape(Rectangle())
            
            mainContent
        }
        .onChange(of: selectedMazeType) { _ in
            if !availableAlgorithms.contains(selectedAlgorithm) {
                if let newAlgo = availableAlgorithms.randomElement() {
                    selectedAlgorithm = newAlgo
                }
            }
        }
        .onChange(of: selectedSize) { newSize in
            if newSize != .large {
                captureSteps = false
            }
        }
        .onAppear {
            if isIPad {
                selectedSize = .large
                captureSteps = false
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Image(colorScheme == .dark ? "LogoLight" : "LogoDark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60 * fontScale, height: 60 * fontScale)
                    .padding(.bottom, 8)
                
                Text("Omni Mazes & Solutions")
                    .font(.system(size: 14 * fontScale))
                    .foregroundColor(colorScheme == .dark ? Color(hex: "B3B3B3") : Color.lightModeSecondary)
                    .italic()
            }
            .padding(.bottom, 8)
            
            if !isIPad {
                Picker("Cell Size", selection: $selectedSize) {
                    ForEach(CellSize.allCases) { size in
                        Text(size.label)
                            .tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .tint(colorScheme == .dark ? Color.lightSkyBlue : Color.orangeRed)
            }
            
            Picker("Maze Type", selection: $selectedMazeType) {
                ForEach(MazeType.allCases.filter { $0 != .polar }) { type in
                    Text(type.rawValue.capitalized)
                        .font(.system(size: 16 * fontScale, weight: .bold))
                        .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(colorScheme == .dark ? Color.lightSkyBlue : Color.orangeRed)
            .onChange(of: selectedMazeType) { _ in
                if !availableAlgorithms.contains(selectedAlgorithm) {
                    if let newAlgo = availableAlgorithms.randomElement() {
                        selectedAlgorithm = newAlgo
                    }
                }
            }
            
            Text(selectedMazeType.description)
                .font(.system(size: 12 * fontScale))
                .foregroundColor(colorScheme == .dark ? .secondary : Color.lightModeSecondary)
                .padding(.horizontal)
            
            Picker("Algorithm", selection: $selectedAlgorithm) {
                ForEach(availableAlgorithms) { algo in
                    Text(algo.displayName)
                        .font(.system(size: 16 * fontScale, weight: .bold))
                        .tag(algo)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(colorScheme == .dark ? Color.lightSkyBlue : Color.orangeRed)
            
            Text(selectedAlgorithm.description)
                .font(.system(size: 12 * fontScale))
                .foregroundColor(colorScheme == .dark ? .secondary : Color.lightModeSecondary)
                .padding(.horizontal)
            
            if !isIPad {
                HStack(spacing: 10) {
                    Text("Show Maze Generation")
                        .font(.system(size: 16 * fontScale))
                        .foregroundColor(colorScheme == .dark ? Color.lightSkyBlue : Color.orangeRed)
//                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Toggle("", isOn: $captureSteps)
                        .labelsHidden()
                        .tint(colorScheme == .dark ? Color.lightSkyBlue : Color.orangeRed)
                        .disabled(selectedSize != .large)
                }
                .padding(.horizontal)
                
                if selectedSize != .large {
                    Text("Show Maze Generation is only available for large cell sizes.")
                        .font(.system(size: 12 * fontScale))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }

            Button(action: submitMazeRequest) {
                Text("Generate")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderedProminent)
            .tint(colorScheme == .dark ? .secondary : Color.orangeRed)
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

    private func filterAndClampWidthInput(_ value: String, max: Int) -> String {
        if let intValue = Int(value), intValue >= 0 && intValue <= max {
            return String(intValue)
        }
        return String(max - 1)
    }
    
    private func filterAndClampHeightInput(_ value: String, max: Int, defaultHeight: Int) -> String {
        if let intValue = Int(value), intValue >= 0 && intValue <= max {
            return String(intValue)
        }
        return String(defaultHeight)
    }
}

