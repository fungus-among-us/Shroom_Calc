# Claude Context: Compound Calculator

This document provides technical context for AI assistants working on the Compound Calculator Flutter application.

## Project Overview

A cross-platform Flutter app for calculating psilocybin/psilocin compound amounts from mushroom strains. Supports two calculation modes: given material mass (dry/wet) calculate total compounds, or given target dose calculate required material.

**Tech Stack:**
- Flutter 3.24+ with Material Design 3
- BLoC pattern for state management
- Freezed for immutable models
- JSON serialization with json_serializable
- GitHub Actions CI/CD for 5 platforms

## Architecture

### State Management: BLoC Pattern

**Location:** `lib/logic/calculator/`

The app uses flutter_bloc for state management with a unidirectional data flow:

```
UI Event → BLoC → New State → UI Update
```

**Key Files:**
- `calculator_bloc.dart`: Business logic coordinator
- `calculator_event.dart`: Freezed union of all events
- `calculator_state.dart`: Immutable state with computed properties

**Important:** State contains input strings (not parsed values). Computed properties like `massInputValue` parse on-demand. This keeps state serializable and validation explicit.

### Data Layer: Repository Pattern

**Location:** `lib/data/`

Three-layer architecture:
1. **Models** (`models/`): Freezed immutable classes
2. **Sources** (`sources/`): HTTP and local storage
3. **Repository** (`repositories/`): Coordinates sources, provides unified API

**Models:**
- `Profile`: Mushroom strain with compounds
- `Compound`: Name + mg_per_g concentration
- `CalculationResult`: Output with mode-specific fields
- `DosingRange`: Reference ranges for microdose/regular/heroic

All models use Freezed with `const` constructor and optional custom methods.

### Calculation Engine

**Location:** `lib/logic/engine/calculation_engine.dart`

Pure Dart static methods. No state, fully testable. Two main functions:

1. **`calculateFromMaterial()`**: Mode A (material → dose)
   - Input: mass, mass type (dry/wet), dry percentage, optional body weight
   - Output: total mg per compound, optional mg/kg

2. **`calculateFromDose()`**: Mode B (dose → material)
   - Input: target mg/kg, body weight, dry percentage
   - Output: required dry/wet mass to achieve target

**Validation:** Centralized in `_validateInputs()` with constants from `AppConstants`.

### UI Structure

**Location:** `lib/presentation/`

Three main screens with bottom navigation:
1. **Calculator** (`calculator/`): Main calculation interface
2. **Library** (`library/`): Searchable profile browser with fuzzy matching
3. **Settings** (`settings/`): Weight units, JSON editor, backups

**Widget Decomposition:**
- Large screens broken into focused widgets
- Each widget folder has `widgets/` subdirectory
- Naming: `<feature>_<component>.dart` (e.g., `mass_input_section.dart`)

## Key Files and Responsibilities

### Core
- `lib/core/constants.dart`: App-wide constants, JSON URL, validation limits
- `lib/core/theme.dart`: Material 3 theme with earthy color palette (#8B7355)

### Main
- `lib/main.dart`: App entry, dependency injection, navigation shell

### Tests
- `test/logic/engine/calculation_engine_test.dart`: 30+ unit tests for all calculation scenarios

## Design Decisions

### Why BLoC over Riverpod/Provider?
- Explicit event/state separation makes complex state machines clearer
- Built-in async/stream handling for HTTP requests
- Strong separation of business logic from UI

### Why Freezed?
- Immutable models prevent accidental mutations
- CopyWith for efficient state updates
- Union types for events reduce boilerplate
- JSON serialization integration

### Why Repository Pattern?
- Future-proof: Easy to add remote backend later
- Testable: Mock repositories for unit tests
- Flexible: Swap local storage without touching BLoC

### Earthy Color Palette
User requested warm, natural aesthetic aligned with mushroom theme:
- Primary: #8B7355 (mushroom brown)
- Background: #FFFBF7 (warm white)
- Surface: #F0EBE6 (light tan)
- Secondary: #4A6741 (forest green)

**Rationale:** Avoids clinical/sterile feel. Makes app feel organic and nature-focused.

### UI Language Choices
- "By Weight" not "Material → Dose": More intuitive for users
- "Target Dose" not "Dose → Material": Clearer intent
- Disclaimer at bottom: Keeps results view clean
- No compound count in profile selector: Redundant (all have 2)

## Important Conventions

### Code Generation

Always run after modifying models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Generates:
- `*.freezed.dart`: Freezed copyWith, equality, etc.
- `*.g.dart`: JSON serialization methods

### Import Order

```dart
// 1. Flutter/Dart
import 'package:flutter/material.dart';

// 2. External packages
import 'package:flutter_bloc/flutter_bloc.dart';

// 3. Internal (relative)
import '../../data/models/profile.dart';
```

### State Updates in BLoC

Always use `emit()`, never mutate state:

```dart
// ✅ Correct
emit(state.copyWith(massInput: '2.5'));

// ❌ Wrong (won't trigger rebuild)
state = state.copyWith(massInput: '2.5');
```

### Calculated Properties

Put computed values in state class as getters, not BLoC:

```dart
// In calculator_state.dart
double? get massInputValue {
  if (massInput == null || massInput!.isEmpty) return null;
  return double.tryParse(massInput!);
}

// In BLoC, reference as state.massInputValue
```

## Common Tasks

### Add a New Profile Field

1. Update `lib/data/models/profile.dart`
2. Run build_runner: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Update `Profile.fromJsonFlexible()` to parse new field
4. Update UI to display new field

### Add a New Calculation Mode

1. Add enum value to `CalculationMode` in `calculation_result.dart`
2. Add input fields to `CalculatorState`
3. Implement calculation method in `calculation_engine.dart`
4. Create input section widget in `lib/presentation/calculator/widgets/`
5. Add tests

### Change Color Palette

1. Update color constants in `lib/core/theme.dart`
2. Update any hardcoded colors in widgets (search for `Color(0x`)
3. Run app to verify contrast/readability

### Update JSON URL

1. Edit `lib/core/constants.dart`
2. Update `profilesJsonUrl` constant
3. Rebuild app

## Testing

### Test Structure

```
test/
├── logic/
│   └── engine/
│       └── calculation_engine_test.dart  # Core calculation tests
└── data/
    └── models/
        └── [model]_test.dart              # Serialization tests
```

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific file
flutter test test/logic/engine/calculation_engine_test.dart

# Watch mode
flutter test --watch
```

### Test Philosophy

- **Calculation engine**: Exhaustive unit tests for all modes, edge cases
- **Models**: Serialization round-trip tests
- **BLoC**: Mock repository, test event → state transitions
- **Widgets**: Minimal (complex setup, brittle), rely on manual testing

## CI/CD

### Workflows

**`.github/workflows/ci.yml`** (on every push/PR):
- Linting: `flutter analyze`
- Tests: `flutter test`
- Build verification (no artifacts)

**`.github/workflows/release.yml`** (on version tags `v*`):
- Builds all 5 platforms
- Creates GitHub Release
- Uploads: APK, AAB, IPA (unsigned), Windows ZIP, macOS DMG, Linux tarball

### Creating a Release

```bash
# Update version in pubspec.yaml
# version: 1.0.0+1

# Tag and push
git tag v1.0.0
git push origin v1.0.0

# Wait ~20 minutes for all builds to complete
```

## Known Issues & Gotchas

### Freezed Private Constructor

The `const ClassName._();` must be INSIDE the class, not outside:

```dart
// ✅ Correct
@freezed
class Profile with _$Profile {
  const factory Profile({...}) = _Profile;
  const Profile._();  // Inside!

  Compound? get primaryCompound { ... }
}

// ❌ Wrong (won't compile)
@freezed
class Profile with _$Profile {
  const factory Profile({...}) = _Profile;
}
const Profile._();  // Outside - ERROR!
```

### CardTheme Type Error

Some Flutter versions expect `CardThemeData?` not `CardTheme`. If build fails, remove `cardTheme:` property from `ThemeData` entirely (it's optional).

### Mode B Requires Body Weight

Mode B (dose → material) ALWAYS needs body weight because target dose is in mg/kg. The UI enforces this, but calculation engine validates it too.

### JSON Parsing Flexibility

`Profile.fromJsonFlexible()` exists because the original PyQt6 app used slightly different field names. The standard `fromJson()` is generated by json_serializable. Use `fromJsonFlexible()` when downloading profiles; use `fromJson()` for locally stored JSON.

### Input String vs Parsed Value

State stores user input as strings (`massInput: '2.5'`). This allows:
- Preserving partial input ("2." is valid while typing)
- Validation errors show actual input
- Easy restore from saved state

Parse with computed properties (`massInputValue`) only when needed.

## File Organization Patterns

### Feature-First Structure

```
lib/presentation/
└── calculator/
    ├── calculator_screen.dart       # Main screen
    └── widgets/
        ├── mass_input_section.dart
        ├── dose_input_section.dart
        └── results_display.dart
```

Not component-first (e.g., `lib/widgets/buttons/`). Features are self-contained.

### BLoC Naming

- **Events**: `<Feature>Event.<action>` (e.g., `CalculatorEvent.calculatePressed`)
- **State**: `<Feature>State` (single class, not unions)
- **BLoC**: `<Feature>Bloc` (extends `Bloc<Event, State>`)

## Debugging Tips

### BLoC Events Not Firing

Add `Bloc.observer = SimpleBlocObserver();` to `main()`:

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    print('Event: $event');
    super.onEvent(bloc, event);
  }
}
```

### Freezed Code Not Updating

Delete generated files, rebuild:
```bash
rm lib/**/*.freezed.dart lib/**/*.g.dart
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hot Reload Not Working

Some changes require hot restart (Shift+R in flutter run):
- Enum changes
- Const constructor changes
- Main function changes

## Performance Notes

- **Build cost:** Entire state tree rebuilds on state change. BlocBuilder rebuilds only when state changes.
- **List optimization:** Profile library uses ListView.builder (lazy loading).
- **Calculation:** Pure Dart, <1ms on modern hardware even with 50 profiles.

## Accessibility

- All interactive elements have semantic labels
- Color contrast meets WCAG AA (tested)
- Font sizes respect system settings
- No critical information conveyed by color alone

## Future Enhancements (Not Yet Implemented)

- [ ] Dark mode (theme defined, not wired up)
- [ ] Profile favoriting
- [ ] Export results as PDF/image
- [ ] Multiple compound targets in Mode B
- [ ] Localization (i18n)
- [ ] Tablet-optimized layouts

## Questions for User

If implementing new features, confirm:
- **Add complexity?** User values simplicity. Don't over-engineer.
- **Change color scheme?** Earthy palette was carefully chosen.
- **Add third mode?** Keep it simple. Two modes already cover most use cases.
- **Change labels?** "By Weight" and "Target Dose" were user-requested.

## Resources

- **Flutter Docs:** https://docs.flutter.dev/
- **BLoC Library:** https://bloclibrary.dev/
- **Freezed:** https://pub.dev/packages/freezed
- **Material 3:** https://m3.material.io/

---

**Last Updated:** 2026-01-13
**Flutter Version:** 3.24+
**Dart Version:** 3.5+
