#!/bin/bash

# This script ensures all Swift files are included in the build
# In a real project, these would be added through Xcode's GUI

echo "Building JubileeWatch with all source files..."

# Find all Swift files
SWIFT_FILES=$(find JubileeWatch/JubileeWatch -name "*.swift" -type f | tr '\n' ' ')

# Build using swiftc directly for testing
swiftc -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
      -target arm64-apple-ios17.0-simulator \
      -framework SwiftUI \
      -framework MapKit \
      -framework AVKit \
      -framework Charts \
      $SWIFT_FILES \
      -o JubileeWatch_test

echo "Build completed!"