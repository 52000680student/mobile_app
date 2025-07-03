# Mobile App

A Flutter application built with clean architecture, featuring localization, environment management, and comprehensive API integration.

## Features

### 🌐 **Multi-Language Support**

- Built-in internationalization (i18n)
- Support for English and Spanish (easily extendable)
- Dynamic language switching

### 🔧 **Environment Management**

- Development, Staging, and Production configurations
- Environment-specific API URLs and settings
- Secure configuration management

### 🌐 **API Integration**

- Complete HTTP client using Dio
- Request/response interceptors
- Authentication handling with token refresh
- Global error handling
- Network connectivity monitoring

### 🏗️ **Clean Architecture**

- BLoC pattern for state management
- Dependency injection using GetIt
- Separation of concerns (Data, Domain, Presentation)
- Either pattern for error handling

### 🎨 **Modern UI/UX**

- Material 3 design system
- Light and dark theme support
- Responsive design
- Custom widgets and components

### 🧪 **Testing Ready**

- Unit testing setup
- Widget testing configuration
- BLoC testing with mocktail
- Test coverage tools

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and routes
│   ├── di/                # Dependency injection setup
│   ├── env/               # Environment configuration
│   ├── error/             # Error handling (failures & exceptions)
│   ├── network/           # API client and interceptors
│   ├── router/            # GoRouter configuration
│   ├── theme/             # App themes and styling
│   └── utils/             # Utility classes
├── features/
│   ├── auth/              # Authentication feature
│   │   └── presentation/  # BLoC, pages, widgets
│   ├── home/              # Home feature
│   │   └── presentation/  # Pages and widgets
│   └── splash/            # Splash screen feature
│       └── presentation/  # BLoC, pages
├── l10n/                  # Localization files
│   ├── app_en.arb        # English translations
│   └── app_es.arb        # Spanish translations
└── main.dart              # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd mobile_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code** (for dependency injection and serialization)

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Generate localizations**
   ```bash
   flutter gen-l10n
   ```

### Running the App

#### Development Environment

```bash
flutter run
```

#### Different Environments

To run with specific environments, modify the `main.dart` file:

```dart
// For development
await EnvConfig.initialize(env: Environment.dev);

// For staging
await EnvConfig.initialize(env: Environment.sta);

// For production
await EnvConfig.initialize(env: Environment.prod);
```

## Configuration

### Environment Variables

The app supports three environments with different configurations:

#### Development (.env.dev)

- API URL: `https://api-dev.yourapp.com`
- Logging: Enabled
- Debug Mode: Enabled

#### Staging (.env.sta)

- API URL: `https://api-staging.yourapp.com`
- Logging: Enabled
- Debug Mode: Disabled

#### Production (.env.prod)

- API URL: `https://api.yourapp.com`
- Logging: Disabled
- Debug Mode: Disabled

### Adding New Languages

1. Add new `.arb` file in `lib/l10n/`:

   ```bash
   lib/l10n/app_fr.arb  # For French
   ```

2. Update `l10n.yaml` if needed

3. Add locale to `main.dart`:

   ```dart
   supportedLocales: const [
     Locale('en'),
     Locale('es'),
     Locale('fr'), // Add new locale
   ],
   ```

4. Generate localizations:
   ```bash
   flutter gen-l10n
   ```

## API Integration

### Making API Calls

The app includes a complete API client setup. To make API calls:

1. **Create a data source** in the appropriate feature:

   ```dart
   @injectable
   class UserRemoteDataSource {
     final ApiClient _apiClient;

     UserRemoteDataSource(this._apiClient);

     Future<UserModel> getUser(String id) async {
       final response = await _apiClient.get('/users/$id');
       return UserModel.fromJson(response.data);
     }
   }
   ```

2. **Handle in repository**:
   ```dart
   @injectable
   class UserRepository {
     final UserRemoteDataSource _remoteDataSource;

     UserRepository(this._remoteDataSource);

     Future<Either<Failure, User>> getUser(String id) async {
       try {
         final user = await _remoteDataSource.getUser(id);
         return Right(user.toEntity());
       } on ServerException catch (e) {
         return Left(ServerFailure(message: e.message));
       }
     }
   }
   ```

### Authentication

The app includes automatic token management:

- Tokens are automatically added to requests
- Automatic token refresh on 401 responses
- Secure token storage

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_bloc_test.dart
```

### Writing Tests

Example BLoC test:

```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] when login is successful',
  build: () => AuthBloc(),
  act: (bloc) => bloc.add(LoginRequested(
    email: 'test@example.com',
    password: 'password123',
  )),
  expect: () => [AuthLoading(), AuthSuccess()],
);
```

## Building for Production

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Code Generation

The project uses code generation for:

- Dependency injection (`injectable_generator`)
- JSON serialization (`json_serializable`)
- Localizations (`flutter gen-l10n`)

Run code generation:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Contributing

1. Follow the existing code structure
2. Add tests for new features
3. Update documentation as needed
4. Follow Flutter best practices
5. Use conventional commit messages

## Dependencies

### Main Dependencies

- `flutter_bloc` - State management
- `get_it` & `injectable` - Dependency injection
- `go_router` - Navigation
- `dio` - HTTP client
- `dartz` - Functional programming (Either type)
- `flutter_dotenv` - Environment variables

### Development Dependencies

- `build_runner` - Code generation
- `injectable_generator` - DI code generation
- `json_serializable` - JSON serialization
- `bloc_test` - BLoC testing
- `mocktail` - Mocking for tests

### Run

- 'flutter run --dart-define=ENV=dev' - Run with environment

## License

This project is licensed under the MIT License - see the LICENSE file for details.
