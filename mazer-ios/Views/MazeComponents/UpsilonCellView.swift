
import SwiftUI
import Darwin

struct UpsilonCellView: View {
    let cell: MazeCell
    let gridCellSize: CGFloat
    let squareSize: CGFloat
    let isSquare: Bool
    let fillColor: Color
    let optionalColor: Color?
    let defaultBackgroundColor: Color = .gray

    private let overlap: CGFloat = 1.0 / UIScreen.main.scale
    
//    private var strokeWidth: CGFloat {
//        let raw = gridCellSize / 12 // Adjust divisor for desired thickness
//        let scale = UIScreen.main.scale
//        return (raw * scale).rounded() / scale
//    }
    private var strokeWidth: CGFloat {
        wallStrokeWidth(for: .upsilon, cellSize: gridCellSize)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Base shape with fill color, adjusted for overlap
            if isSquare {
                let adjustedSize = squareSize + 2 * overlap
                let adjustedOffset = (gridCellSize - adjustedSize) / 2
                Rectangle()
                    .fill(fillColor)
                    .frame(width: adjustedSize, height: adjustedSize)
                    .offset(x: adjustedOffset, y: adjustedOffset)
            } else {
                OctagonShape(overlap: overlap)
                    .fill(fillColor)
                    .frame(width: gridCellSize, height: gridCellSize)
            }
            
            // Wall overlay (unchanged, precise boundaries)
            WallView(cell: cell, gridCellSize: gridCellSize, squareSize: squareSize, isSquare: isSquare, strokeWidth: strokeWidth)
                .frame(width: gridCellSize, height: gridCellSize)
        }
        .frame(width: gridCellSize, height: gridCellSize)
        // Removed .clipShape to allow overlap
    }
}

struct OctagonShape: Shape {
    let overlap: CGFloat

    init(overlap: CGFloat = 0) {
        self.overlap = overlap
    }

    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2 + overlap
        let k = (2.0 * r) / (2.0 + Darwin.sqrt(2.0))
        let points = [
            CGPoint(x: cx - r + k, y: cy - r),
            CGPoint(x: cx + r - k, y: cy - r),
            CGPoint(x: cx + r, y: cy - r + k),
            CGPoint(x: cx + r, y: cy + r - k),
            CGPoint(x: cx + r - k, y: cy + r),
            CGPoint(x: cx - r + k, y: cy + r),
            CGPoint(x: cx - r, y: cy + r - k),
            CGPoint(x: cx - r, y: cy - r + k)
        ]
        var path = Path()
        path.move(to: points[0])
        for point in points[1...] {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        pathBuilder = { shape.path(in: $0) }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

struct WallView: View {
    let cell: MazeCell
    let gridCellSize: CGFloat
    let squareSize: CGFloat
    let isSquare: Bool
    let strokeWidth: CGFloat

    var body: some View {
        Path { path in
            if isSquare {
                let offset = (gridCellSize - squareSize) / 2
                let points = [
                    CGPoint(x: offset, y: offset),                    // Top-left
                    CGPoint(x: offset + squareSize, y: offset),       // Top-right
                    CGPoint(x: offset + squareSize, y: offset + squareSize), // Bottom-right
                    CGPoint(x: offset, y: offset + squareSize)        // Bottom-left
                ]
                let directions: [String: (Int, Int)] = [
                    "Up": (0, 1),
                    "Right": (1, 2),
                    "Down": (2, 3),
                    "Left": (3, 0)
                ]
                for (dir, (start, end)) in directions {
                    if !cell.linked.contains(dir) {
                        path.move(to: points[start])
                        path.addLine(to: points[end])
                    }
                }
            } else {
                let s = gridCellSize
                let cx = s / 2
                let cy = s / 2
                let r = s / 2
                let k = (2.0 * r) / (2.0 + Darwin.sqrt(2.0))
                let points = [
                    CGPoint(x: cx - r + k, y: cy - r), // 0: Top-left of top
                    CGPoint(x: cx + r - k, y: cy - r), // 1: Top-right of top
                    CGPoint(x: cx + r, y: cy - r + k), // 2: Right-top
                    CGPoint(x: cx + r, y: cy + r - k), // 3: Right-bottom
                    CGPoint(x: cx + r - k, y: cy + r), // 4: Bottom-right of bottom
                    CGPoint(x: cx - r + k, y: cy + r), // 5: Bottom-left of bottom
                    CGPoint(x: cx - r, y: cy + r - k), // 6: Left-bottom
                    CGPoint(x: cx - r, y: cy - r + k)  // 7: Left-top
                ]
                let directions: [String: (Int, Int)] = [
                    "Up": (0, 1),       // Top horizontal side
                    "UpperRight": (1, 2), // Top-right diagonal
                    "Right": (2, 3),    // Right vertical side
                    "LowerRight": (3, 4), // Bottom-right diagonal
                    "Down": (4, 5),     // Bottom horizontal side
                    "LowerLeft": (5, 6), // Bottom-left diagonal
                    "Left": (6, 7),     // Left vertical side
                    "UpperLeft": (7, 0)  // Top-left diagonal
                ]
                for (dir, (start, end)) in directions {
                    if !cell.linked.contains(dir) {
                        path.move(to: points[start])
                        path.addLine(to: points[end])
                    }
                }
            }
        }
        .stroke(Color.black, lineWidth: strokeWidth)
    }
}
