# mazer-ios
iOS app using the `mazer` Rust library for generating and solving mazes.

---

## Setup Instructions

### **Initial Setup & Updating the `mazer` Library**
1. **Run `setup.sh`** (from the root of `mazer-ios/`)  
    - This script installs Rust (`rustup`) if not already installed.
    - It **removes any existing `mazer/` directory**, pulls the latest version **from GitHub** as a submodule, and installs dependencies.
    - It explicitly updates `mazer/Cargo.toml` to ensure:
      ```toml
      [lib]
      crate-type = ["staticlib"]
      ```
    - After a successful setup, you should see the compiled static library:  
      ```
      mazer/target/aarch64-apple-ios/debug/libmazer.a
      ```

2. **Add `libmazer.a` to the Xcode project**
    1. Open Xcode and your `mazer-ios` project.
    2. In the project navigator, select your iOS app target.
    3. Click the **"Build Phases"** tab.
    4. Expand **"Link Binary With Libraries"** and click the `"+"` button.
    5. Click **"Add Other..."** → **"Add Files..."**.
    6. Navigate to `mazer/target/aarch64-apple-ios/debug/` and select `libmazer.a`.
    7. Click `"Add"`.

3. **Add the Header File (`mazer.h`)**
    1. Drag and drop `mazer.h` into the Xcode project.
    2. Ensure it is added to your app target.

4. **Expose the `mazer` Library to Swift via a Bridging Header**
    *Creating a bridging header allows Swift to call the `mazer` library’s C functions.*
    1. In Xcode, go to **File** → **New** → **File...** → **Header File**.
    2. Name it `mazer_bridge.h` (or a similar name).
    3. Inside the file, add:
       ```c
       #include "mazer.h"
       ```
    4. In Xcode, go to **Build Settings** and search for **"Objective-C Bridging Header"**.
    5. Set the path to your bridging header:  
       ```
       mazer-ios/mazer_bridge.h
       ```

