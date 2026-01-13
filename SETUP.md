# Flutter Compound Calculator - Setup Guide

## Quick Start

This guide will help you get the Flutter compound calculator up and running.

## Prerequisites Checklist

- [ ] Flutter SDK 3.24.0+ installed
- [ ] Dart SDK (included with Flutter)
- [ ] Platform-specific tools (see below)

### Platform-Specific Prerequisites

**Android:**
- [ ] Android Studio
- [ ] Android SDK (API 23+)
- [ ] Android emulator or physical device

**iOS (macOS only):**
- [ ] Xcode
- [ ] iOS Simulator or physical device
- [ ] CocoaPods: `sudo gem install cocoapods`

**Windows:**
- [ ] Visual Studio 2022
- [ ] "Desktop development with C++" workload

**macOS:**
- [ ] Xcode Command Line Tools

**Linux:**
```bash
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

## Step 1: Configure Profile Data Source

**IMPORTANT**: Before building, set your profile JSON URL.

Edit `lib/core/constants.dart`:
```dart
static const String profilesJsonUrl = 'https://your-domain.com/profiles.json';
```

The JSON must be publicly accessible via HTTPS and follow the required format (see README.md).

## Step 2: Install Dependencies

```bash
cd flutter_app
flutter pub get
```

This downloads all required packages listed in `pubspec.yaml`.

## Step 3: Generate Code

The app uses code generation for data models. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` files (immutable data classes)
- `*.g.dart` files (JSON serialization)

**Note:** You'll need to run this whenever you modify model files.

## Step 4: Verify Setup

Check if Flutter can see your devices:

```bash
flutter devices
```

Run Flutter Doctor to identify any issues:

```bash
flutter doctor -v
```

Fix any issues reported (you don't need ALL platforms, just the one(s) you're targeting).

## Step 5: Run the App

### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run with hot reload (recommended for development)
flutter run --hot
```

### Production Build

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Google Play):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (macOS only):**
```bash
flutter build ios --release --no-codesign
# Output: build/ios/iphoneos/Runner.app
```

**Windows:**
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

**macOS:**
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/compound_calculator.app
```

**Linux:**
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

## Step 6: Test

Run the test suite:

```bash
flutter test
```

Run with coverage report:

```bash
flutter test --coverage
```

## Common Issues

### Issue: "No devices found"
**Solution:**
- Android: Start an emulator via Android Studio
- iOS: Open Simulator.app on macOS
- Desktop: Desktop support is auto-detected

### Issue: "Waiting for another flutter command"
**Solution:**
```bash
killall -9 dart
flutter pub get
```

### Issue: Build runner fails
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Failed to load profiles" on first launch
**Solution:**
- Verify `profilesJsonUrl` in `lib/core/constants.dart`
- Check URL is accessible (test in browser)
- Ensure JSON format matches spec (see README.md)
- Check network permissions in platform configs

### Issue: iOS build fails with signing errors
**Solution:** This is expected without an Apple Developer account. Use `--no-codesign` flag.

## Development Workflow

1. Make code changes
2. If models changed: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Hot reload: Press `r` in terminal or save file (if using IDE)
4. Run tests: `flutter test`
5. Check linting: `flutter analyze`

## Next Steps

- Read `README.md` for full documentation
- Check `docs/plans/2026-01-13-flutter-compound-calculator-design.md` for architecture details
- Review GitHub Actions workflows in `.github/workflows/` for CI/CD setup
- Customize app branding (name, icon, colors in `lib/core/theme.dart`)

## Getting Help

- Flutter docs: https://docs.flutter.dev/
- Flutter Discord: https://discord.gg/N7Yshp4
- Stack Overflow: Tag your question with `flutter`

## Production Checklist

Before releasing:

- [ ] Updated `profilesJsonUrl` with production URL
- [ ] Tested on real devices (not just emulators)
- [ ] Ran full test suite: `flutter test`
- [ ] No lint errors: `flutter analyze`
- [ ] Updated version in `pubspec.yaml`
- [ ] Created git tag for release
- [ ] Tested profile editing and restore functionality
- [ ] Verified calculations are accurate
- [ ] Added appropriate disclaimers and legal info
- [ ] Set up app icons (if distributing)
- [ ] Configured app signing (Android/iOS if publishing to stores)
