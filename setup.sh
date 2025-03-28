#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 [DEVELOP|RELEASE]"
    echo "  DEVELOP  - Sets up the environment for iOS simulator (aarch64-apple-ios-sim)"
    echo "  RELEASE  - Sets up the environment for real iOS devices (aarch64-apple-ios)"
    echo "  --help   - Show this help message"
    exit 1
}

# Ensure an argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Missing required argument."
    usage
fi

# Handle --help option
if [[ "$1" == "--help" ]]; then
    usage
fi

# Convert argument to uppercase for case-insensitive comparison
ARG=$(echo "$1" | tr '[:lower:]' '[:upper:]')

# Validate argument and set the correct Rust target
case "$ARG" in
    DEVELOP)
        TARGET="aarch64-apple-ios-sim"
        ;;
    RELEASE)
        TARGET="aarch64-apple-ios"
        ;;
    *)
        echo "Error: Unexpected argument '$1'. Expected DEVELOP or RELEASE."
        usage
        ;;
esac

echo "Setting up environment for $ARG mode with target: $TARGET"

# Ensure Homebrew is up-to-date
echo "Updating Homebrew..."
brew update

# Install necessary dependencies
echo "Installing dependencies..."
brew install cmake libssh2 pkg-config openssl

# Check if rustup is installed
if ! command -v rustup &>/dev/null; then
    echo "rustup not found! Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
    echo "rustup is already installed"
fi

# Set the Rust toolchain to stable if not already configured
echo "Setting up Rust toolchain..."
rustup default stable

# Add the target for iOS development
echo "Adding Rust target: $TARGET..."
rustup target add "$TARGET"

# Ensure we're in the correct directory
echo "Running setup from $(pwd)"

# Check if mazer/ exists; if not, clone it
if [ ! -d "mazer" ]; then
    echo "Cloning mazer repository..."
    git clone https://github.com/jmisabella/mazer.git mazer
else
    echo "Updating mazer submodule..."
    git -C mazer pull origin main
fi

# Navigate into mazer directory
cd mazer || { echo "Error: 'mazer' directory not found"; exit 1; }

# Remove old build artifacts to ensure a fresh build
echo "Cleaning up old build artifacts..."
rm -rf target/

# Update dependencies to fetch the latest crates.io version
echo "Updating dependencies from crates.io..."
cargo update

echo "Ensuring crate-type is set to staticlib in Cargo.toml..."

# Check if [lib] section already exists
if grep -q '^\[lib\]' Cargo.toml; then
    # If crate-type is missing inside [lib], add it
    if ! grep -q 'crate-type = \["staticlib"\]' Cargo.toml; then
        sed -i '' '/^\[lib\]/a\
crate-type = ["staticlib"]
' Cargo.toml
        echo "Updated [lib] section in Cargo.toml to include crate-type staticlib."
    fi
else
    # If [lib] section does not exist, insert it at the beginning of the file
    sed -i '' '1i\
[lib]\
crate-type = ["staticlib"]
' Cargo.toml
    echo "Added [lib] section to Cargo.toml with crate-type staticlib."
fi

# Copy include/mazer.h to mazer-ios/ so it can be easily added to Xcode
if [[ -f "include/mazer.h" ]]; then
    cp "include/mazer.h" ../mazer.h
    echo "File 'mazer.h' copied to mazer-ios directory."
else
    echo "Error: 'mazer.h' does not exist in 'mazer/include/'."
fi

# Build mazer library for the selected iOS target
echo "Building mazer library for target: $TARGET..."
cargo build --target "$TARGET"

# Navigate back to mazer-ios directory
cd ..

# Check if Xcode command line tools are installed
echo "Checking for Xcode command line tools..."
xcode-select --install

# Print Rust and target information to verify setup
echo "Rust setup completed. Current Rust version:"
rustc --version
echo "Target added for iOS ($TARGET):"
rustup target list --installed

# End of script
echo "Setup complete! You should now be ready to build the iOS app with Rust integration."

