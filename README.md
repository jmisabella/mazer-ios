# mazer-ios
iOS app using the mazer Rust library for building mazes and solving them

---

### Steps for Initial Setup as well as Re-Downloading Latest mazer Library from Crates.IO
1. Run setup.sh
    - This step removes any existing mazer library installation, pulls down the latest, and installs it. It also installs rustup if it is not already installed.
    - The script explicitly updates mazer/Cargo.toml to force it to have crate-type = ["staticlib"]
    - After successfully installing mazer as a submodule to the mazer-ios project you should see the packaged file mazer/target/aarch64-apple-ios/debug/libmazer.a
2. Add libmazer.a to the Xcode project
    1. Open Xcode and your mazer-ios project.
    2. In the project navigator, select your iOS app target.
    3. Click the "Build Phases" tab.
    4. Expand "Link Binary With Libraries" and click the "+" button.
    5. Click "Add Other..." → "Add Files...".
    6. Navigate to mazer/target/aarch64-apple-ios/debug/ and select libmazer.a.
    7. Click "Add".
3. Add Header File mazer.h
    1. Drag and drop mazer.h into the Xcode project.
    2. Ensure it's added to your app target.
4. Expose the mazer Header to Swift (Bridging Header)
    - Creating the bridging header allows Swift to call the mazer library's C functions.
    1. In Xcode, go to File → New → File... → Header File.
    2. Name it mazer\_bridge.h (or something similar).
    3. Add this line inside:
        #include mazer.h
    4. Go to Build Settings → Search for Objective-C Bridging Header.
    5. Set the path to your bridging header (mazer-ios/mazer\_bridge.h).
  
