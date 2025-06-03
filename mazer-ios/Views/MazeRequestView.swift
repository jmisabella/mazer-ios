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
    @State private var didRandomizeOnAppear = false
    
    @Environment(\.colorScheme) private var colorScheme
    
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
    
    private var availableAlgorithms: [MazeAlgorithm] {
        if selectedMazeType == .orthogonal {
            return MazeAlgorithm.allCases
        } else {
            return MazeAlgorithm.allCases
                .filter { ![.binaryTree, .sidewinder].contains($0) }
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
            // Conditional background: off-white in light mode, black in dark mode
            (colorScheme == .dark ? Color.black : Color.offWhite)
                .ignoresSafeArea()
                .contentShape(Rectangle())
            
            mainContent // Extracted VStack content
        }
        .onChange(of: selectedMazeType) { _ in
            randomizeAlgorithm()
            if !availableAlgorithms.contains(selectedAlgorithm),
               let firstValid = availableAlgorithms.first {
                selectedAlgorithm = firstValid
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Image(colorScheme == .dark ? "LogoLight" : "LogoDark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60 * fontScale, height: 60 * fontScale) // Adjust size as needed
                    .padding(.bottom, 8)
                
//                LayeredTitleView(text: "Maze Quest", fontScale: fontScale, colorScheme: colorScheme)
                Text("Omni Mazes & Solutions")
                    .font(.system(size: 14 * fontScale))
                    .foregroundColor(colorScheme == .dark ? Color(hex: "B3B3B3")  : Color(hex: "333333"))
                    .italic()
            }
            .padding(.bottom, 8)
            
            Picker("Maze Size", selection: $selectedSize) {
                ForEach(MazeSize.allCases) { size in
                    Text(size.label)
                        .tag(size)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(colorScheme == .dark ? Color.softOrange : Color.orangeRed)
            
            Picker("Maze Type", selection: $selectedMazeType) {
                ForEach(MazeType.allCases.filter { $0 != .polar }) { type in
                    Text(type.rawValue.capitalized)
                        .font(.system(size: 16 * fontScale, weight: .bold))
                        .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(colorScheme == .dark ? Color.softOrange : Color.orangeRed)
            .onChange(of: selectedMazeType) { _ in
                randomizeAlgorithm()
                if !availableAlgorithms.contains(selectedAlgorithm),
                   let firstValid = availableAlgorithms.first {
                    selectedAlgorithm = firstValid
                }
            }
            
            Text(selectedMazeType.description)
                .font(.system(size: 12 * fontScale))
                .foregroundColor(colorScheme == .dark ? .secondary : Color(hex: "333333"))
                .padding(.horizontal)
            
            Picker("Algorithm", selection: $selectedAlgorithm) {
                ForEach(availableAlgorithms) { algo in
                    Text(algo.rawValue)
                        .font(.system(size: 16 * fontScale, weight: .bold))
                        .tag(algo)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(colorScheme == .dark ? Color(hex: "FFCCBC") : Color.orangeRed)
            
            Text(selectedAlgorithm.description)
                .font(.system(size: 12 * fontScale))
                .foregroundColor(colorScheme == .dark ? .secondary : Color(hex: "333333"))
                .padding(.horizontal)

            Button(action: submitMazeRequest) {
                Text("Generate")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderedProminent)
//            .tint(Color.orangeRed)
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

struct LayeredTitleView: View {
    let text: String
    let fontScale: CGFloat
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            // Background text (black in light mode, gray in dark mode)
            Text(text)
                .font(.custom("Arial-BoldMT", size: 28 * fontScale))
                .foregroundColor(colorScheme == .dark ? .gray : .black)
                .offset(x: 1, y: 1)
            
            // Foreground text (#f66e6e)
            Text(text)
                .font(.custom("Arial-BoldMT", size: 28 * fontScale))
                .foregroundColor(Color(hex: "f66e6e"))
        }
    }
}

//import SwiftUI
//
//struct MazeRequestView: View {
//    
//    @Binding var mazeCells: [MazeCell]
//    @Binding var mazeGenerated: Bool
//    @Binding var mazeType: MazeType
//    @Binding var selectedSize: MazeSize
//    @Binding var selectedMazeType: MazeType
//    @Binding var selectedAlgorithm: MazeAlgorithm
//    
//    let submitMazeRequest: () -> Void
//    
//    @State private var errorMessage: String? = nil
//    @State private var didRandomizeOnAppear = false
//    
//    @Environment(\.colorScheme) private var colorScheme
//    
//    private let horizontalMargin = 10 // TODO: this number must match hard-coded offsets in ContentView! Must couple these 2 variables to address this
//    private let verticalMargin = 280 // TODO: this number must match hard-coded offsets in ContentView! Must couple these 2 variables to address this
//    
//    private var maxWidth: Int {
//        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
//    }
//
//    private var maxHeight: Int {
//        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
//    }
//    
//    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
//    
//    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
//    
//    private var availableWidth: CGFloat {
//        screenWidth - CGFloat(horizontalMargin)
//    }
//    
//    private var availableHeight: CGFloat {
//        screenHeight - CGFloat(verticalMargin)
//    }
//    
//    private var mazeWidth: Int {
//        max(1, Int(availableWidth / CGFloat(selectedSize.rawValue)))
//    }
//    
//    private var mazeHeight: Int {
//        max(1, Int(availableHeight / CGFloat(selectedSize.rawValue)))
//    }
//    
//    private var fontScale: CGFloat {
//        screenWidth > 700 ? 1.3 : 1.0
//    }
//    
//    private var availableAlgorithms: [MazeAlgorithm] {
//        if selectedMazeType == .orthogonal {
//            return MazeAlgorithm.allCases
//        } else {
//            return MazeAlgorithm.allCases
//                .filter { ![.binaryTree, .sidewinder].contains($0) }
//        }
//    }
//        
//    private func randomizeType() {
//        let types = MazeType.allCases.filter { $0 != .polar }
//        if let randomType = types.randomElement() {
//            selectedMazeType = randomType
//        }
//    }
//        
//    private func randomizeAlgorithm() {
//        if let algo = availableAlgorithms.randomElement() {
//            selectedAlgorithm = algo
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            // Conditional background: off-white in light mode, black in dark mode
//            (colorScheme == .dark ? Color.black : Color.offWhite)
//                .ignoresSafeArea()
//                .contentShape(Rectangle())
//            
//            VStack(spacing: 20) {
//                VStack(spacing: 4) {
//                    LayeredTitleView(text: "Maze Quest", fontScale: fontScale, colorScheme: colorScheme)
//                    Text("Omni Mazes & Solutions")
//                        .font(.system(size: 14 * fontScale))
//                        .foregroundColor(colorScheme == .dark ? .secondary : Color.lightGrey) // Darker gray in light mode
//                }
//                .padding(.bottom, 8)
//                
//                Picker("Maze Size", selection: $selectedSize) {
//                    ForEach(MazeSize.allCases) { size in
//                        Text(size.label)
//                            .tag(size)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .tint(Color.orangeRed)
//
//                Picker("Maze Type", selection: $selectedMazeType) {
//                    ForEach(MazeType.allCases.filter { $0 != .polar }) { type in
//                        Text(type.rawValue.capitalized)
//                            .font(.system(size: 16 * fontScale), weight: .bold)
//                            .tag(type)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//                .tint(Color.orangeRed)
//                .onChange(of: selectedMazeType) { _ in
//                    randomizeAlgorithm()
//                    if !availableAlgorithms.contains(selectedAlgorithm),
//                       let firstValid = availableAlgorithms.first
//                    {
//                        selectedAlgorithm = firstValid
//                    }
//                }
//                
//                Text(selectedMazeType.description)
//                    .font(.system(size: 12 * fontScale))
//                    .foregroundColor(colorScheme == .dark ? .secondary : Color.lightGrey) // Darker gray in light mode
//                    .padding(.horizontal)
//                
//                Picker("Algorithm", selection: $selectedAlgorithm) {
//                    ForEach(availableAlgorithms) { algo in
//                        Text(algo.rawValue)
//                            .font(.system(size: 16 * fontScale), weight: .bold)
//                            .tag(algo)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//                .tint(Color.orangeRed)
//                
//                Text(selectedAlgorithm.description)
//                    .font(.system(size: 12 * fontScale))
//                    .foregroundColor(colorScheme == .dark ? .secondary : Color.lightGrey) // Darker gray in light mode
//                    .padding(.horizontal)
//
//                Button(action: submitMazeRequest) {
//                    Text("Generate Maze")
//                        .foregroundColor(colorScheme == .dark ? .black : .white) // Fixed from Color.offWhite
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(Color.orangeRed)
//                .padding()
//
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                }
//
//                Divider()
//            }
//            .padding()
//        }
//        .onChange(of: selectedMazeType) { _ in
//            randomizeAlgorithm()
//            if !availableAlgorithms.contains(selectedAlgorithm),
//               let firstValid = availableAlgorithms.first {
//                selectedAlgorithm = firstValid
//            }
//        }
//    }
//
//    private func filterAndClampWidthInput(_ value: String, max: Int) -> String {
//        if let intValue = Int(value), intValue >= 0 && intValue <= max {
//            return String(intValue)
//        }
//        return String(max - 1)
//    }
//    
//    private func filterAndClampHeightInput(_ value: String, max: Int, defaultHeight: Int) -> String {
//        if let intValue = Int(value), intValue >= 0 && intValue <= max {
//            return String(intValue)
//        }
//        return String(defaultHeight)
//    }
//}
//
//struct LayeredTitleView: View {
//    let text: String
//    let fontScale: CGFloat
//    let colorScheme: ColorScheme
//    
//    var body: some View {
//        ZStack {
//            // Background text (black in light mode, gray in dark mode)
//            Text(text)
//                .font(.custom("Arial-BoldMT", size: 28 * fontScale))
//                .foregroundColor(colorScheme == .dark ? .gray : .black)
//                .offset(x: 1, y: 1)
//            
//            // Foreground text (#f66e6e)
//            Text(text)
//                .font(.custom("Arial-BoldMT", size: 28 * fontScale))
//                .foregroundColor(Color.orangeRed)
//        }
//    }
//}
