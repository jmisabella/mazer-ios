# mazer-ios
iOS app using the `mazer` Rust library for generating and solving mazes.

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
    1. In Xcode Project Navigator, click on the inner `mazer-ios/` subfolder. Go to **File** → **New** → **File from Template...** → **Header File** *(from `iOS/Source`)*.
    2. Name it `mazer_bridge.h` (or a similar name) and **make sure the `mazer-ios` Target is checked**.
    3. Copy the contents of `mazer.h` (in outer-most `mazer-ios/` folder) into `mazer_bridge.h`.
    4. Click on the root `mazer-ios` folder in Project Navigator.
    5. Go to the **Build Settings** tab and search for **"Objective-C Bridging Header"**.
    6. Click on **Objective-C Bridging Header** to expand it.
    7. Click the + button on Debug and enter `${PROJECT_DIR}/mazer-ios/mazer_bridge.h` for its value.
    8. Click the + button on Release and enter `${PROJECT_DIR}/mazer-ios/mazer_bridge.h` for its value.

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

