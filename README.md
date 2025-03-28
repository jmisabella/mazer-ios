# mazer-ios
iOS app using the `mazer` Rust library for generating and solving mazes.

---

## Setup Instructions
1. **Download and Prepare the `mazer` Rust Library for iOS Development**
    1. Run `setup.sh` from the root of `mazer-ios/`. 
    2. After a successful setup, you should see the compiled static library:  
      ```
      mazer/target/aarch64-apple-ios/debug/libmazer.a
      ```

2. **Create a New Xcode Project**
    - If you haven't already, create a new Xcode project for an iOS app in the root mazer-ios/ directory.

3. **Add `libmazer.a` to the Xcode Project**
    1. Open Xcode and your `mazer-ios` project.
    2. In the project navigator, select your iOS app target.
    3. Click the **"Build Phases"** tab.
    4. Expand **"Link Binary With Libraries"** and click the `"+"` button.
    5. Click **"Add Other..."** → **"Add Files..."**.
    6. Navigate to `mazer/target/aarch64-apple-ios/debug/` and select `libmazer.a`.
    7. Click `"Add"`.


4. **Set Up the Bridging Header** *(allows Swift to call the `mazer` library's C functions)*
    1. In Xcode, go to **File** → **New** → **File...** → **Header File** (under Source.
    2. Name it `mazer_bridge.h` (or a similar name).
    3. Add the following line to `mazer_bridge.h`. This line will allow the bridger header to import the Rust-generated header.:
       ```c
       #include "mazer.h"
       ```
    4. Click on the root `mazer-ios` folder in Project Navigator. Go to the **Build Settings** tab and search for **"Objective-C Bridging Header"**.
    5. Set the path to your bridging header:  
       ```
       mazer-ios/mazer_bridge.h
       ```
    6. Make sure the bridging header is properly associated with your Xcode project.

5. **Add the `mazer.h` Header File**
    1. Drag and drop `mazer.h` into the Xcode project.
    2. Ensure it is added to your app target.

