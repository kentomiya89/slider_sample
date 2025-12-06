# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter project named "slider_sample" using Flutter SDK 3.10.3+. The project uses FVM (Flutter Version Manager) with Flutter version 3.38.4 configured in `.fvmrc`.

## Development Commands

### Flutter Version Management
This project uses FVM to manage Flutter versions:
```bash
fvm flutter [command]  # Run Flutter commands through FVM
```

### Running the Application
```bash
fvm flutter run                    # Run on default device
fvm flutter run -d <device-id>     # Run on specific device
fvm flutter devices                # List available devices
```

### Building
```bash
fvm flutter build apk              # Build Android APK
fvm flutter build ios              # Build iOS app
fvm flutter build appbundle        # Build Android App Bundle
```

### Testing
```bash
fvm flutter test                   # Run all tests
fvm flutter test test/widget_test.dart  # Run specific test file
```

### Code Quality
```bash
fvm flutter analyze                # Run static analysis
fvm flutter pub outdated           # Check for outdated dependencies
fvm flutter pub upgrade            # Upgrade dependencies
```

### Dependencies
```bash
fvm flutter pub get                # Install dependencies
fvm flutter pub add <package>      # Add a new dependency
```

## Project Structure

- `lib/main.dart` - Application entry point with a standard Flutter counter demo app
  - `MyApp` - Root application widget with MaterialApp configuration
  - `MyHomePage` - Stateful widget demonstrating basic state management
- `test/` - Test files
- `.fvmrc` - FVM configuration specifying Flutter version 3.38.4

## Code Style

The project uses `flutter_lints` package (v6.0.0) with recommended lints enabled via `analysis_options.yaml`. All code should comply with these lint rules.
