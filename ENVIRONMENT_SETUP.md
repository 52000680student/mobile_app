# 🌍 Environment Configuration Setup

This document explains how to set up environment files for your Flutter application.

## 📁 Required Environment Files

Create the following three environment files in your project root directory:

### 1. `.env.dev` (Development Environment)

```env
ENVIRONMENT=dev
API_BASE_URL=https://api-dev.yourapp.com
API_TIMEOUT=30000
ENABLE_LOGGING=true
DEBUG_MODE=true

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mobile_app_dev

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=true
ENABLE_DEBUG_MENU=true

# Third-party Keys (Development)
GOOGLE_MAPS_API_KEY=your_dev_google_maps_key
FIREBASE_PROJECT_ID=mobile-app-dev
SENTRY_DSN=your_dev_sentry_dsn

# App Configuration
APP_NAME=Mobile App (Dev)
APP_VERSION=1.0.0-dev
MIN_SUPPORTED_VERSION=1.0.0
```

### 2. `.env.sta` (Staging Environment)

```env
ENVIRONMENT=sta
API_BASE_URL=https://api-staging.yourapp.com
API_TIMEOUT=30000
ENABLE_LOGGING=true
DEBUG_MODE=false

# Database Configuration
DB_HOST=staging-db.yourapp.com
DB_PORT=5432
DB_NAME=mobile_app_staging

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_DEBUG_MENU=false

# Third-party Keys (Staging)
GOOGLE_MAPS_API_KEY=your_staging_google_maps_key
FIREBASE_PROJECT_ID=mobile-app-staging
SENTRY_DSN=your_staging_sentry_dsn

# App Configuration
APP_NAME=Mobile App (Staging)
APP_VERSION=1.0.0-staging
MIN_SUPPORTED_VERSION=1.0.0
```

### 3. `.env.prod` (Production Environment)

```env
ENVIRONMENT=prod
API_BASE_URL=https://api.yourapp.com
API_TIMEOUT=30000
ENABLE_LOGGING=false
DEBUG_MODE=false

# Database Configuration
DB_HOST=prod-db.yourapp.com
DB_PORT=5432
DB_NAME=mobile_app_production

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_DEBUG_MENU=false

# Third-party Keys (Production)
GOOGLE_MAPS_API_KEY=your_prod_google_maps_key
FIREBASE_PROJECT_ID=mobile-app-prod
SENTRY_DSN=your_prod_sentry_dsn

# App Configuration
APP_NAME=Mobile App
APP_VERSION=1.0.0
MIN_SUPPORTED_VERSION=1.0.0
```

## 🔧 How to Create Environment Files

1. **Create the files in your project root:**
   ```bash
   # Windows (PowerShell)
   New-Item -Path ".env.dev" -ItemType File
   New-Item -Path ".env.sta" -ItemType File
   New-Item -Path ".env.prod" -ItemType File
   
   # macOS/Linux
   touch .env.dev .env.sta .env.prod
   ```

2. **Copy the content above into each respective file**

3. **Replace placeholder values with your actual configuration:**
   - Update API URLs to match your backend
   - Replace API keys with real values
   - Configure database connections
   - Set up third-party service credentials

## 🚀 Usage in Your Application

The environment files are automatically loaded based on your build configuration:

```dart
import 'package:mobile_app/core/env/env_config.dart';

// Access environment variables
String apiUrl = EnvConfig.apiBaseUrl;
bool isDebugMode = EnvConfig.debugMode;
String appName = EnvConfig.appName;
```

## 🛠️ Available Environment Variables

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `ENVIRONMENT` | Current environment (dev/sta/prod) | String | ✅ |
| `API_BASE_URL` | Base URL for API calls | String | ✅ |
| `API_TIMEOUT` | Request timeout in milliseconds | Integer | ✅ |
| `ENABLE_LOGGING` | Enable/disable logging | Boolean | ✅ |
| `DEBUG_MODE` | Enable/disable debug features | Boolean | ✅ |
| `DB_HOST` | Database host | String | ❌ |
| `DB_PORT` | Database port | Integer | ❌ |
| `DB_NAME` | Database name | String | ❌ |
| `ENABLE_ANALYTICS` | Enable/disable analytics | Boolean | ❌ |
| `ENABLE_CRASH_REPORTING` | Enable/disable crash reporting | Boolean | ❌ |
| `ENABLE_DEBUG_MENU` | Show/hide debug menu | Boolean | ❌ |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key | String | ❌ |
| `FIREBASE_PROJECT_ID` | Firebase project ID | String | ❌ |
| `SENTRY_DSN` | Sentry DSN for error tracking | String | ❌ |
| `APP_NAME` | Application display name | String | ❌ |
| `APP_VERSION` | Application version | String | ❌ |
| `MIN_SUPPORTED_VERSION` | Minimum supported app version | String | ❌ |

## 🔒 Security Best Practices

1. **Never commit .env files to version control:**
   ```gitignore
   # Add to .gitignore
   .env*
   !.env.example
   ```

2. **Create a .env.example template:**
   ```env
   ENVIRONMENT=dev
   API_BASE_URL=https://your-api-url.com
   API_TIMEOUT=30000
   GOOGLE_MAPS_API_KEY=your_google_maps_key
   # ... other variables without values
   ```

3. **Use different API keys for each environment**

4. **Store production secrets securely (e.g., CI/CD environment variables)**

## 📱 Running with Different Environments

Configure your IDE or build scripts to use different environment files:

### VS Code Launch Configuration (`.vscode/launch.json`):
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENV=dev"]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENV=sta"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENV=prod"]
    }
  ]
}
```

### Build Commands:
```bash
# Development
flutter run --dart-define=ENV=dev

# Staging
flutter run --dart-define=ENV=sta

# Production
flutter run --dart-define=ENV=prod

# Build for production
flutter build apk --dart-define=ENV=prod
flutter build ios --dart-define=ENV=prod
```

## 🔄 Environment Switching

The app automatically loads the correct environment file based on the `ENV` dart-define parameter:
- No parameter or `ENV=dev` → loads `.env.dev`
- `ENV=sta` → loads `.env.sta`
- `ENV=prod` → loads `.env.prod`

## 📝 Notes

- Environment files are loaded during app initialization
- Changes to environment files require app restart
- The `EnvConfig` class provides type-safe access to all environment variables
- Fallback values are provided for all variables to prevent runtime errors

Remember to replace all placeholder values with your actual configuration before using in production! 