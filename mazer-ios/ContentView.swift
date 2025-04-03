//
//  ContentView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 3/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var ffi_integration_test_result: Int32 = 0
    @State private var mazeCells: [MazeCell] = []
    @State private var errorMessage: String?  // Add error message state if not already declared
    
    var body: some View {
        VStack {
            MazeRequestView(mazeCells: $mazeCells)
            
            // Optionally display any error messages
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//#Preview {
//    ContentView()
//}
