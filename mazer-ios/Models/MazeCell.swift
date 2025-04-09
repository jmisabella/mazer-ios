struct MazeCell : Hashable {
    let x: Int
    let y: Int
    let mazeType: String
    let linked: [String]
    let distance: Int
    let isStart: Bool
    let isGoal: Bool
    let isVisited: Bool
    let onSolutionPath: Bool
    let orientation: String
}

