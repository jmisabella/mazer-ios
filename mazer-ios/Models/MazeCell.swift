struct MazeCell : Hashable {
    let x: Int
    let y: Int
    let mazeType: String
    let linked: [String]
    let distance: Int
    let isStart: Bool
    let isGoal: Bool
    let isActive: Bool
    let isVisited: Bool
    let hasBeenVisited: Bool
    let onSolutionPath: Bool
    let orientation: String
}

