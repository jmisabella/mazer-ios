import SwiftUI
import UIKit
import AudioToolbox

struct DeltaMazeView: View {
    let cells: [MazeCell]
    let cellSize: CGFloat
    let showSolution: Bool
    let showHeatMap: Bool
    let selectedPalette: HeatMapPalette
    let maxDistance: Int
    let defaultBackgroundColor: Color
    let optionalColor: Color?
    private let totalRows: Int
    
    @State private var pendingWorkItems: [DispatchWorkItem] = []
    @State private var revealedSolutionPath: Set<Coordinates> = []

    @Environment(\.colorScheme) private var colorScheme

    var columns: Int { (cells.map { $0.x }.max() ?? 0) + 1 }
    var rows: Int { (cells.map { $0.y }.max() ?? 0) + 1 }

    private func snap(_ x: CGFloat) -> CGFloat {
        let scale = UIScreen.main.scale
        return (x * scale).rounded() / scale
    }

    private var triangleHeight: CGFloat { cellSize * sqrt(3) / 2 }

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private static let defaultCellBackgroundColors: [Color] = [
        CellColors.defaultCellBackgroundGray,
        CellColors.defaultCellBackgroundMint,
        CellColors.defaultCellBackgroundPeach,
        CellColors.defaultCellBackgroundLavender,
        CellColors.defaultCellBackgroundBlue
    ]

    @State private var currentDefaultBackgroundColor: Color

    private let cellMap: [Coordinates: MazeCell]
    
    private var rowIndices: [Int] { Array(0..<rows) }
    private var colIndices: [Int] { Array(0..<columns) }
    
    init(cells: [MazeCell],
         cellSize: CGFloat,
         showSolution: Bool,
         showHeatMap: Bool,
         selectedPalette: HeatMapPalette,
         maxDistance: Int,
         defaultBackgroundColor: Color,
         optionalColor: Color?
    ) {
        self.cells = cells
        self.cellSize = cellSize
        self.showSolution = showSolution
        self.showHeatMap = showHeatMap
        self.selectedPalette = selectedPalette
        self.maxDistance = maxDistance
        self.defaultBackgroundColor = defaultBackgroundColor
        self.optionalColor = optionalColor
        
        self.cellMap = Dictionary(
            uniqueKeysWithValues: cells.map { cell in
                (Coordinates(x: cell.x, y: cell.y), cell)
            }
        )
        
        self.totalRows = (cells.map { $0.y }.max() ?? 0) + 1
        
        _currentDefaultBackgroundColor = State(initialValue:
                    Self.defaultCellBackgroundColors.randomElement()!
                )
    }

    var body: some View {
        let totalWidth = snap(cellSize * CGFloat(columns) * 0.75)
        let totalHeight = snap(triangleHeight * CGFloat(rows))

        ZStack {
            Color.clear
                .frame(width: totalWidth, height: totalHeight)
            
            VStack(spacing: snap(0)) {
                ForEach(rowIndices, id: \.self) { row in
                    rowView(for: row)
                }
            }
            .overlay(alignment: .top) {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: geometry.size.width * 0.9, height: 2)
                        .position(x: geometry.size.width / 2, y: 0)
                }
            }
            .overlay(alignment: .bottom) {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: geometry.size.width * 0.9, height: 2)
                        .position(x: geometry.size.width / 2, y: geometry.size.height)
                }
            }
            .compositingGroup()
            .drawingGroup(opaque: false)
            .clipped(antialiased: false)
        }
        .onChange(of: showSolution) { _, newValue in
            if newValue {
                animateSolutionPathReveal()
            } else {
                pendingWorkItems.forEach { $0.cancel() }
                pendingWorkItems.removeAll()
                revealedSolutionPath = []
            }
        }
        .onChange(of: cells) { _ in
            pendingWorkItems.forEach { $0.cancel() }
            pendingWorkItems.removeAll()
            revealedSolutionPath = []
            currentDefaultBackgroundColor = Self.defaultCellBackgroundColors.randomElement()!
        }
        .onAppear {
            if showSolution { animateSolutionPathReveal() }
        }
    }

    @ViewBuilder
    private func rowView(for row: Int) -> some View {
        HStack(spacing: snap(-cellSize / 2)) {
            ForEach(colIndices, id: \.self) { col in
                cellView(atColumn: col, row: row)
            }
        }
    }

    @ViewBuilder
    private func cellView(atColumn col: Int, row: Int) -> some View {
        if let cell = cellMap[Coordinates(x: col, y: row)] {
            DeltaCellView(
                cell: cell,
                cellSize: cellSize,
                showSolution: showSolution,
                showHeatMap: showHeatMap,
                selectedPalette: selectedPalette,
                maxDistance: maxDistance,
                isRevealedSolution: revealedSolutionPath.contains(Coordinates(x: col, y: row)),
                defaultBackgroundColor: defaultBackgroundColor,
                optionalColor: optionalColor,
                totalRows: totalRows
            )
            .background(Color.clear)
        } else {
            EmptyView()
        }
    }

    func animateSolutionPathReveal() {
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        revealedSolutionPath.removeAll()

        let pathCells = cells
            .filter { $0.onSolutionPath && !$0.isVisited }
            .sorted { $0.distance < $1.distance }

        let rapidDelay: Double = 0.015
        haptic.prepare()
        for (i, cell) in pathCells.enumerated() {
            let coord = Coordinates(x: cell.x, y: cell.y)
            let item = DispatchWorkItem {
                AudioServicesPlaySystemSound(1104)
                haptic.impactOccurred()
                withAnimation(.none) {
                    _ = revealedSolutionPath.insert(coord)
                }
            }
            pendingWorkItems.append(item)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * rapidDelay, execute: item)
        }
    }

    func shadeColor(for cell: MazeCell, maxDistance: Int) -> Color {
        guard showHeatMap, maxDistance > 0 else { return .gray }
        let index = min(9, (cell.distance * 10) / maxDistance)
        return selectedPalette.shades[index].asColor
    }

    func defaultCellColor(for cell: MazeCell) -> Color {
        if cell.isStart { return .blue }
        if cell.isGoal { return .red }
        if cell.onSolutionPath { return .pink }
        return currentDefaultBackgroundColor
    }
}
