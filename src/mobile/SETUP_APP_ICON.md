# App Icon Setup Instructions

## Current Status
The app logo (`logo-uit.svg`) is located in `assets/icons/` but needs to be converted to PNG format for the launcher icon.

## Steps to Complete Setup

### 1. Convert SVG to PNG

You have several options to convert the SVG logo to PNG:

#### Option A: Using Online Tool (Easiest)
1. Go to https://cloudconvert.com/svg-to-png or https://svgtopng.com/
2. Upload `assets/icons/logo-uit.svg`
3. Set the output size to at least **1024x1024 pixels** (recommended for best quality)
4. Download and save as `assets/icons/logo-uit.png`

#### Option B: Using ImageMagick (Command Line)
```powershell
# Install ImageMagick if not already installed
# Then run:
magick convert -background none -size 1024x1024 assets/icons/logo-uit.svg assets/icons/logo-uit.png
```

#### Option C: Using Inkscape (Command Line)
```powershell
# Install Inkscape if not already installed
# Then run:
inkscape assets/icons/logo-uit.svg --export-type=png --export-filename=assets/icons/logo-uit.png --export-width=1024 --export-height=1024
```

#### Option D: Using GIMP or Photoshop
1. Open `assets/icons/logo-uit.svg` in GIMP or Photoshop
2. Export as PNG with size 1024x1024 pixels
3. Save to `assets/icons/logo-uit.png`

### 2. Install Dependencies
After converting the logo to PNG, run:
```powershell
cd src/mobile
flutter pub get
```

### 3. Generate Launcher Icons
Run the flutter_launcher_icons package to generate all platform-specific icons:
```powershell
cd src/mobile
flutter pub run flutter_launcher_icons
```

This will automatically generate:
- Android icons (mipmap folders with different densities)
- iOS icons (AppIcon.appiconset)
- Adaptive icons for Android 8.0+ with white background

### 4. Verify the Icons
Check that icons were generated in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 5. Build and Test
Build your app to see the new icon:
```powershell
# For Android
flutter build apk

# For iOS (requires Mac)
flutter build ios

# Or run in debug mode
flutter run
```

## Configuration Details

The `pubspec.yaml` has been configured with:
- **image_path**: `assets/icons/logo-uit.png` (main logo)
- **adaptive_icon_background**: White background (#FFFFFF)
- **adaptive_icon_foreground**: The logo as foreground
- **Platforms**: Android and iOS enabled
- **remove_alpha_ios**: true (iOS requires opaque icons)

## Troubleshooting

### If the icon doesn't appear:
1. Clean the build: `flutter clean`
2. Rebuild: `flutter pub get` then `flutter run`
3. For Android: Uninstall the app and reinstall
4. For iOS: Clean build folder in Xcode

### If colors look wrong:
- Adjust `adaptive_icon_background` color in `pubspec.yaml`
- Consider creating a version of the logo with transparent background

### If icon is too small/large:
- Ensure PNG is at least 1024x1024 pixels
- The tool will automatically resize for different densities

## Alternative: Manual Icon Setup

If you prefer manual control, you can create icons for each size:

### Android Sizes:
- `mipmap-mdpi`: 48x48
- `mipmap-hdpi`: 72x72
- `mipmap-xhdpi`: 96x96
- `mipmap-xxhdpi`: 144x144
- `mipmap-xxxhdpi`: 192x192

### iOS Sizes:
See `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` for all required sizes.

## Next Steps

1. Convert the SVG to PNG (1024x1024)
2. Save as `assets/icons/logo-uit.png`
3. Run `flutter pub get`
4. Run `flutter pub run flutter_launcher_icons`
5. Build and test your app
