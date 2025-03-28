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
    - If you haven't already, create a new Xcode project for an iOS app in the root `mazer-ios/` directory.

3. **Add `libmazer.a` to the Xcode Project**
    1. In the project navigator, click on the root `mazer-ios` directory (the iOS app target).
    2. Click the **"Build Phases"** tab.
    3. Expand **"Link Binary With Libraries"** and click the `"+"` button.
    4. Click **"Add Other..."** → **"Add Files..."**.
    5. Navigate to `mazer/target/aarch64-apple-ios/debug/` and select `libmazer.a`.
    6. Click `"Add"`.

4. **Set Up the Bridging Header** *(allows Swift to call the `mazer` library's C functions)*
    1. In Xcode, go to **File** → **New** → **File from Template...** → **Header File** *(from `iOS/Source`)*.
    2. Name it `mazer_bridge.h` (or a similar name).
    3. Add the following line to `mazer_bridge.h`:
       ```c
       #include "mazer.h"
       ```
    4. Click on the root `mazer-ios` folder in Project Navigator. 
    5. Go to the **Build Settings** tab and search for **"Objective-C Bridging Header"**.
    6. Click on **Objective-C Bridging Header** to expand it.
    7. Click the + button on Debug and enter `mazer-ios/mazer_bridge.h` for its value. 
    8. Click the + button on Release and enter `mazer-ios/mazer_bridge.h` for its value. 

5. **Add the `mazer.h` Header File**
    1. Drag and drop `mazer.h` into the Xcode project's `mazer-ios/mazer-ios` folder (same directory as Assets).
    2. Ensure it is added to your app target.

