# Compound Calculator

A cross-platform compound potency calculator built with Flutter. Calculate dosing information from mushroom strain profiles with support for dry/wet material and body weight-based calculations.

**Educational purposes only.** This app provides reference calculations based on average compound concentrations. Actual potency can vary significantly between batches.

## Features

- **Dual Calculation Modes**
  - Material → Dose: Calculate total mg and mg/kg from material mass
  - Dose → Material: Calculate required material from target dose

- **Profile Library**
  - Pre-loaded mushroom strain database
  - Fuzzy search with typo tolerance
  - View compound concentrations for all profiles

- **Profile Editing**
  - Direct JSON editing with auto-save
  - Restore to original defaults
  - Validation prevents malformed data

- **Dosing Reference**
  - Expandable accordions showing microdose, regular, and heroic ranges
  - Calculated for any selected profile

- **Clean, Legible UI**
  - Material Design 3 with earthy, natural color palette
  - Warm mushroom brown (#8B7355) primary color
  - Intuitive "By Weight" and "Target Dose" mode labels
  - High readability for critical information
  - Disclaimer positioned at bottom of results for clean viewing

## Supported Platforms

- ✅ Android (API 23+)
- ✅ iOS (sideload only, iOS 12+)
- ✅ Windows 10+
- ✅ macOS 10.14+
- ✅ Linux (Ubuntu/Debian)

## Installation

### Prerequisites

1. **Install Flutter SDK** (3.24.0 or later)
   ```bash
   # Download from: https://docs.flutter.dev/get-started/install
   ```

2. **Platform-specific requirements:**
   - **Android**: Android Studio with SDK
   - **iOS**: Xcode (macOS only)
   - **Windows**: Visual Studio 2022 with C++ desktop development
   - **Linux**: GTK3 development libraries
     ```bash
     sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
     ```

### Build from Source

```bash
# Clone repository
cd flutter_app

# Install dependencies
flutter pub get

# Generate code (freezed/json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on connected device or emulator
flutter run

# Or build for specific platform
flutter build apk --release           # Android APK
flutter build appbundle --release     # Android App Bundle
flutter build ios --release           # iOS (requires macOS)
flutter build windows --release       # Windows
flutter build macos --release         # macOS
flutter build linux --release         # Linux
```

### Download Pre-built Binaries

Download from [GitHub Releases](https://github.com/YOUR_USERNAME/compound-calculator/releases):

- **Android**: `app-release.apk` (direct install) or `app-release.aab` (Google Play)
- **iOS**: `app-unsigned.ipa` (sideload with AltStore/Sideloadly)
- **Windows**: `windows-portable.zip` (extract and run)
- **macOS**: `compound_calculator.dmg` (unsigned, allow in System Preferences)
- **Linux**: `linux-x64.tar.gz` (extract and run)

## Configuration

### Setting the Profile JSON URL

Before building, update the hardcoded JSON URL in:
`lib/core/constants.dart`

```dart
static const String profilesJsonUrl = 'YOUR_PROFILES_JSON_URL_HERE';
```

The JSON should follow this structure:
```json
{
  "source": "Data source 2025",
  "description": "Mushroom strain profiles",
  "profiles": [
    {
      "label": "Strain Name",
      "compounds": [
        { "name": "Psilocybin", "mg_per_g": 7.7 },
        { "name": "Psilocin", "mg_per_g": 0.6 }
      ]
    }
  ]
}
```

## Development

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Constants, themes
├── data/
│   ├── models/                  # Data models (freezed)
│   ├── repositories/            # Data layer coordination
│   └── sources/                 # Local/remote data sources
├── logic/
│   ├── calculator/              # Calculator BLoC
│   ├── library/                 # Library BLoC (future)
│   └── engine/                  # Calculation algorithms
├── presentation/
│   ├── calculator/              # Calculator screen + widgets
│   ├── library/                 # Library browser
│   └── settings/                # Settings + JSON editor
└── services/                    # HTTP, storage services
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/logic/engine/calculation_engine_test.dart
```

### Code Generation

When modifying models, regenerate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

## Architecture

- **State Management**: BLoC pattern (flutter_bloc)
- **Data Models**: Immutable with freezed
- **Serialization**: json_serializable
- **Storage**: shared_preferences + path_provider
- **Navigation**: Bottom navigation with IndexedStack
- **Testing**: Unit tests with mocktail

## CI/CD

GitHub Actions automatically:
- **On Push/PR**: Runs tests, linting, smoke builds
- **On Version Tag** (`v*.*.*`): Builds all platforms, creates GitHub Release

### Creating a Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

Wait for GitHub Actions to build and publish artifacts.

## iOS Sideloading

Since the app is built without an Apple Developer account:

1. Download `app-unsigned.ipa` from releases
2. Install using:
   - **AltStore**: https://altstore.io/ (free, 7-day resign)
   - **Sideloadly**: https://sideloadly.io/ (free, 7-day resign)
   - **Xcode**: Build locally with your free Apple ID

## Privacy

- **No analytics or telemetry**
- **No user data collection**
- **One network call**: Initial profile JSON download
- **All data stored locally**

## License

[Add your license here]

## Disclaimer

**FOR EDUCATIONAL PURPOSES ONLY.**

This calculator provides reference estimates based on average compound concentrations. Actual potency varies significantly between batches—up to 3x variation is common. Always verify compound concentrations independently. The developers assume no liability for the use of this information.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Submit a pull request

## Acknowledgments

- Compound concentration data: [Add source]
- Built with Flutter and Material Design 3
