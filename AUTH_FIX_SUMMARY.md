# Authentication Persistence Fix

## Problem
The app required login every time it was restarted, even though valid tokens were stored in secure storage.

### Root Cause
The `AuthService` constructor was calling token initialization asynchronously via `Future.microtask(() => _init())`. This meant:
1. App started building UI immediately
2. `tokenNotifier.value` was still `null`
3. UI showed login screen
4. Token loaded from storage afterwards (too late)

### Flow Diagram (Before Fix)
```
App Start → AuthService() constructor
  ↓
runApp() → build UI
  ↓
ValueListenableBuilder checks tokenNotifier.value (null)
  ↓
Show Login Screen
  ↓
Future.microtask(_init) completes
  ↓
Token loaded, but UI already decided to show login
```

## Solution
Added a static `initialize()` method to `AuthService` that loads the token **before** the app builds the UI.

### Changes Made

#### 1. AuthService (`lib/services/auth_service.dart`)
- **Removed**: Async initialization in constructor via `Future.microtask()`
- **Added**: Static `initialize()` method that can be awaited
- **Added**: Static storage instance for initialization

```dart
// Before
AuthService() {
  if (!_initialized) {
    _initialized = true;
    Future.microtask(() => _init());
  }
}

// After
AuthService();

static Future<void> initialize() async {
  if (_initialized) return;
  _initialized = true;
  
  try {
    final token = await _staticStorage.read(key: _tokenKey);
    tokenNotifier.value = token;
    developer.log('AuthService: initialized with token ${token == null ? 'null' : '***'}', name: 'AuthService');
  } catch (e) {
    developer.log('AuthService: Error during initialization: $e', name: 'AuthService');
    tokenNotifier.value = null;
  }
}
```

#### 2. Main (`lib/main.dart`)
- **Added**: Call to `await AuthService.initialize()` before `runApp()`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  try {
    await dotenv.load(fileName: 'env/.env');
  } catch (_) {}

  // Initialize AuthService and load saved token before building UI
  await AuthService.initialize();

  runApp(
    MultiProvider(
      // ...providers
      child: const MyApp(),
    ),
  );
}
```

### Flow Diagram (After Fix)
```
App Start
  ↓
main() calls await AuthService.initialize()
  ↓
Token loaded from secure storage
  ↓
tokenNotifier.value set
  ↓
runApp() → build UI
  ↓
ValueListenableBuilder checks tokenNotifier.value (has token)
  ↓
Show Main Screen (user is logged in)
```

## Benefits
1. ✅ **Token loaded before UI renders**: No flash of login screen
2. ✅ **Clean separation**: Initialization is explicit and awaitable
3. ✅ **Predictable behavior**: Token state is known before app starts
4. ✅ **Better UX**: Users stay logged in across app restarts
5. ✅ **Maintains security**: Still uses FlutterSecureStorage with encryption

## Testing
1. Login to the app
2. Close the app completely
3. Reopen the app
4. ✅ Should go directly to Main Screen without showing login

## Files Modified
- `src/mobile/lib/services/auth_service.dart`
- `src/mobile/lib/main.dart`

## Backward Compatibility
- ✅ No breaking changes to existing API
- ✅ All existing auth flows (login, logout, refresh) work as before
- ✅ Token storage and retrieval unchanged
- ✅ Remember-me functionality preserved

