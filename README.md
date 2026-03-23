# MazeR for iOS

A fully offline, free iOS maze app powered by the [MazeR](https://github.com/jmisabella/mazer) Rust library. Generate, solve, and explore mazes across **13 algorithms** and **5 grid types** — all rendered natively in SwiftUI with smooth animations, heat-map hints, and interactive navigation.

<p align="center">
  <em>No ads. No network. No tracking. Just mazes.</em>
</p>

---

## Features

### Maze Generation
- **13 Algorithms** — from classics like Recursive Backtracker and Kruskal's to lesser-known gems like Eller's and Wilson's
- **5 Grid Types** — Orthogonal (square), Sigma (hexagonal), Delta (triangular), Upsilon (octagon + square), and Rhombic (diamond)
- **Configurable Cell Sizes** — Tiny, Small, Medium, and Large to fit your screen and challenge preference
- **Generation Animation** — Watch your maze being carved out step by step

### Navigation & Interaction
- **Gesture Controls** — Swipe and drag to move through the maze
- **On-Screen D-Pad** — Context-aware directional buttons that adapt to the current grid type:
  - 4-way (orthogonal), 8-way (sigma/delta/upsilon), or diagonal (rhombic)
- **Drag & Zoom** — Pan and pinch to explore large mazes
- **Haptic Feedback** — Tactile response on every successful move

### Visualization
- **Heat Map Hints** — Toggle a distance-based color overlay to guide you toward the goal, with **20 color palettes** to choose from
- **Solution Path** — Reveal the optimal path from start to goal
- **Traversal Tracking** — See where you've already explored
- **Celebration Effect** — Sparkle animation and sound when you reach the goal

### Device Support
- iPhone and iPad with responsive layouts
- Dark mode and light mode
- Portrait orientation optimized

---

## Supported Algorithms

| Algorithm | Style | Description |
|---|---|---|
| **Aldous-Broder** | Random walk | Unbiased; wanders randomly until every cell is visited |
| **Binary Tree** | Iterative | Fast and simple; creates a characteristic diagonal bias |
| **Eller's** | Row-by-row | Memory-efficient; builds the maze one row at a time |
| **Growing Tree (Newest)** | Frontier-based | Selects the newest cell from the active list — similar to Recursive Backtracker |
| **Growing Tree (Random)** | Frontier-based | Selects a random cell from the active list — similar to Prim's |
| **Hunt and Kill** | Hybrid | Random walks followed by systematic scans to fill gaps |
| **Kruskal's** | Graph-based | Randomly joins cells using a minimum spanning tree approach |
| **Prim's** | Graph-based | Grows outward from a starting cell by lowest-weight edges |
| **Recursive Backtracker** | Depth-first | Long, winding passages with few dead ends |
| **Recursive Division** | Divisive | Starts open and recursively carves chambers with walls |
| **Reverse Delete** | Subtractive | Begins fully connected and randomly adds walls |
| **Sidewinder** | Row-by-row | Eastward runs with periodic vertical connections |
| **Wilson's** | Random walk | Loop-erased walks producing uniformly random spanning trees |

> Not all algorithms are available for every grid type. For example, Binary Tree and Sidewinder are only available for orthogonal grids.

---

## Grid Types

| Grid | Shape | Description |
|---|---|---|
| **Orthogonal** | Squares | Classic rectangular maze with right-angle turns |
| **Sigma** | Hexagons | Six-sided cells creating organic, web-like paths |
| **Delta** | Triangles | Alternating normal and inverted triangles for jagged corridors |
| **Upsilon** | Octagons + Squares | Alternating shapes offering varied passage widths |
| **Rhombic** | Diamonds | Slanted, diamond-shaped cells with diagonal movement |

---

## Architecture

The app bridges Swift and Rust through a C FFI layer:

```
┌─────────────────────────────────────────────────┐
│                   SwiftUI App                   │
│  ┌───────────┐  ┌────────────┐  ┌────────────┐ │
│  │   Views   │  │   Models   │  │  Utilities  │ │
│  └─────┬─────┘  └─────┬──────┘  └─────┬──────┘ │
│        └───────────────┼───────────────┘        │
│                        ▼                        │
│              Bridging Header (mazer.h)          │
│                        │                        │
│                        ▼                        │
│          ┌─────────────────────────┐            │
│          │  libmazer.a (Rust FFI)  │            │
│          └─────────────────────────┘            │
└─────────────────────────────────────────────────┘
```

**Key FFI functions:**
- `mazer_generate_maze` — accepts a JSON request, returns a maze grid
- `mazer_make_move` — processes a directional move, returns updated state
- `mazer_get_cells` — retrieves current cell data for rendering
- `mazer_get_generation_step_cells` — retrieves intermediate states for animation

### Project Structure

```
mazer-ios/
├── mazer-ios/                    # Swift source
│   ├── Models/                   # Data structures (cells, algorithms, directions)
│   ├── Views/
│   │   ├── MazeComponents/       # Grid-type-specific renderers
│   │   ├── DirectionControls/    # D-pad variants per grid type
│   │   └── Effects/              # Sparkle, loading, GIF animations
│   ├── Layout/                   # Device-aware sizing and appearance
│   └── Utilities/                # Validation, color helpers
├── mazer/                        # MazeR Rust library (git submodule)
├── mazer.h                       # C bridging header for FFI
└── setup.sh                      # Rust → iOS build script
```

---

## Setup Instructions
1. **Download and Prepare the `mazer` Rust Library for iOS Development**
    1. Run `setup.sh` from the root of `mazer-ios/` with either `DEVELOP` or `RELEASE` as an argument:
       ```sh
       ./setup.sh DEVELOP  # For iOS Simulator (aarch64-apple-ios-sim)
       ./setup.sh RELEASE  # For real iOS devices (aarch64-apple-ios)
       ```
    2. After a successful setup, you should see the compiled static library:
       - For **DEVELOP** (Simulator):
         ```
         mazer/target/aarch64-apple-ios-sim/debug/libmazer.a
         ```
       - For **RELEASE** (Device):
         ```
         mazer/target/aarch64-apple-ios/debug/libmazer.a
         ```

2. **Create a New Xcode Project**
    - If you haven't already, create a new Xcode project for an iOS app in the root `mazer-ios/` directory.

3. **Add `libmazer.a` to the Xcode Project**
    1. In the project navigator, click on the root `mazer-ios` directory (the iOS app target).
    2. Click the **"Build Phases"** tab.
    3. Expand **"Link Binary With Libraries"** and click the `"+"` button.
    4. Click **"Add Other..."** → **"Add Files..."**.
    5. Navigate to the appropriate build directory and select `libmazer.a`:
       - If using `DEVELOP`, navigate to:
         ```
         mazer/target/aarch64-apple-ios-sim/debug/
         ```
       - If using `RELEASE`, navigate to:
         ```
         mazer/target/aarch64-apple-ios/debug/
         ```
    6. Click `"Add"`.

4. **Set Up the Bridging Header** *(allows Swift to call the `mazer` library's C functions)*
    1. In Xcode Project Navigator, right-click on the inner `mazer-ios/` subfolder. Select **Add Files to "mazer-ios"...**. Select `mazer.h` (in outer-most `mazer-ios/` folder).
    2. Click on the root `mazer-ios` folder in Project Navigator.
    3. Go to the **Build Settings** tab and search for **"Objective-C Bridging Header"**.
    4. Click on **Objective-C Bridging Header** to expand it.
    5. Click the + button on Debug and enter `${PROJECT_DIR}/mazer-ios/mazer.h` for its value.
    6. Click the + button on Release and enter `${PROJECT_DIR}/mazer-ios/mazer.h` for its value.

5. **Verify FFI Connection**
    1. Add this line to ContentView to define `ffi_integration_test_result`:
    ```
    @State private var ffi_integration_test_result: Int32 = 0
    ```
    2. Prepend the following to ContentView body's outer-most VStack:
    ```
    .onAppear {
        ffi_integration_test_result = mazer_ffi_integration_test()
        print("mazer_ffi_integration_test returned: \(ffi_integration_test_result)")

        // Verify result is 42
        if ffi_integration_test_result == 42 {
            print("FFI integration test passed ✅")
        } else {
            print("FFI integration test failed ❌")
        }
    }
    ```

    3. Verify you see the output: `FFI integration test passed`

---

## License

This project uses the [MazeR](https://github.com/jmisabella/mazer) Rust library as its maze generation and solving engine.
