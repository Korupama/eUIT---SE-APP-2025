# eUIT Mobile App (Flutter)

## Project Structure
- `lib/core` - Core utilities, constants, themes
- `lib/features` - Feature modules (screens, widgets)
- `lib/services` - API and business logic services
- `assets` - Images, fonts, etc.
- `env` - Environment variable files

## Getting Started
1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Copy `env/.env.example` to `env/.env` and set your API URL.
3. Install dependencies:
	```
	flutter pub get
	```
4. Run the app:
	```
	flutter run
	```

## API Communication
- Uses `http` for REST API calls
- Uses `flutter_dotenv` for environment variables

## Backend
- .NET 8 Web API (see `src/backend`)

---

For more details, see the main project README.
# mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
