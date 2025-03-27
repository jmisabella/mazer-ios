#!/bin/bash

set -e  # Exit immediately if a command fails

echo "🔄 Initializing Git submodules..."
git submodule update --init --recursive

# If the submodule is not added already, add it manually
if [ ! -d "mazer" ]; then
    echo "🔽 Cloning the mazer submodule..."
    git submodule add https://github.com/jmisabella/mazer.git mazer
    git submodule update --init --recursive
fi

echo "🔍 Checking for Cargo installation..."
if ! command -v cargo &> /dev/null
then
    echo "❌ Cargo is not installed. Install Rust from https://www.rust-lang.org/tools/install"
    exit 1
fi

echo "🔍 Checking for iOS Rust targets..."
if ! cargo --list | grep -q "target"; then
    echo "⚠️  Unable to verify installed targets, but proceeding..."
else
    if ! cargo target list | grep -q "aarch64-apple-ios"; then
        echo "❌ Required Rust target (aarch64-apple-ios) is missing."
        echo "⚠️  Please manually install it using: cargo install <appropriate-target-tool>"
        exit 1
    fi
fi

echo "🔨 Building Rust library for iOS..."
cd mazer
cargo build --release --target aarch64-apple-ios || { echo "❌ Rust build failed"; exit 1; }

echo "📂 Copying built library to Xcode project..."
cp target/aarch64-apple-ios/release/libmazer.a ../

echo "✅ Setup complete! Now open Xcode and build the project."

