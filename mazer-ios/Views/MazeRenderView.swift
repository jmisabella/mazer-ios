//
//  MazeRenderView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 4/3/25.
//

import SwiftUI

struct MazeRenderView: View {
    let mazeCells: [MazeCell] // Binding unnecessary here because mazeCells is read-only, doesn't need changed from this View
    
    var body: some View {
        ScrollView {
//            LazyVGrid(columns: [...]) {
//                ForEach(cells, id: \.self) { cell in
//                    // Render each MazeCell however you like
//                    Text("(\(cell.x),\(cell.y))")
//                        .padding(4)
//                        .background(cell.isOnSolutionPath ? Color.green : Color.gray)
//                        .cornerRadius(4)
//                }
//            }
        }
    }
}

struct MazeRenderView_Previews: PreviewProvider {
    static var previews: some View {
        MazeRenderView(mazeCells: []) // pass empty array for preview
    }
}
