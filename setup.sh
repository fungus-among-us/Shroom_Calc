#!/bin/bash
set -e

echo "🍄 Compound Calculator Setup Script"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✓ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Check Flutter doctor
echo "Running Flutter doctor..."
flutter doctor
echo ""

# Get dependencies
echo "Installing dependencies..."
flutter pub get
echo ""

# Run code generation
echo "Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs
echo ""

# Run tests
echo "Running tests..."
flutter test
echo ""

echo "✅ Setup complete!"
echo ""
echo "To run the app:"
echo "  flutter run"
echo ""
echo "To build for release:"
echo "  flutter build apk    # Android"
echo "  flutter build ios    # iOS (requires macOS)"
echo "  flutter build windows # Windows"
echo "  flutter build linux  # Linux"
echo "  flutter build macos  # macOS"
