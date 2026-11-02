# firebase_app_update

A Flutter package for checking app updates using Firebase Remote Config. It detects the installed app version, identifies optional or mandatory updates, displays an update dialog, and opens the appropriate app store.

## Features

- Check installed app versions against Firebase Remote Config.
- Support optional (soft) and mandatory (force) updates.
- Compare semantic versions, including prerelease versions.
- Configure Android and iOS update settings independently.
- Display built-in update dialogs.
- Open Google Play Store and Apple App Store links.
- Configure Remote Config fetch timeout and minimum fetch interval.
- Use the update result to implement your own UI.
- Support dependency injection for easier testing.

## Getting started

### Requirements

- Flutter SDK compatible with this package's SDK constraints.
- A Firebase project with Firebase Remote Config enabled.
- Firebase configured for your Flutter application.
- Android or iOS for platform-specific update checking.

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_app_update: ^0.1.0
```

Then run:

```bash
flutter pub get
```

If the package has not yet been published, use a local path dependency during development:

```yaml
dependencies:
  firebase_app_update:
    path: ../
```

### Initialize Firebase

Configure Firebase by following the [official FlutterFire setup guide](https://firebase.google.com/docs/flutter/setup).

Initialize Firebase before using the package:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}
```

If you use FlutterFire CLI-generated configuration, initialize Firebase with `DefaultFirebaseOptions.currentPlatform` as described in the setup guide.

## Firebase Remote Config setup

Create the following parameters in Firebase Console under **Remote Config**.

| Parameter | Example value | Description |
|---|---|---|
| `android_min_version` | `1.0.0` | Minimum supported Android version |
| `android_latest_version` | `1.2.0` | Latest Android version |
| `android_force_update` | `false` | Force an update when an update is available |
| `android_update_message` | `A new version is available.` | Android update message |
| `android_store_url` | Play Store listing URL | Android store link |
| `ios_min_version` | `1.0.0` | Minimum supported iOS version |
| `ios_latest_version` | `1.2.0` | Latest iOS version |
| `ios_force_update` | `false` | Force an update when an update is available |
| `ios_update_message` | `A new version is available.` | iOS update message |
| `ios_store_url` | App Store listing URL | iOS store link |

Replace the example values with your app's actual versions, messages, and store URLs. Publish your Remote Config changes when ready.

### Update behavior

The package determines the update type by comparing the installed version with the configured versions.

| Condition | Result |
|---|---|
| Installed version is at or above the latest version | `UpdateType.none` |
| Installed version is below the latest version but meets the minimum version | `UpdateType.soft`, unless force update is enabled |
| Installed version is below the minimum supported version | `UpdateType.force` |
| An update is available and the platform's force-update flag is enabled | `UpdateType.force` |

Keep `min_version` less than or equal to `latest_version`.

## Usage

### 1. Check for updates

Use `AppUpdateService` when you want to check for an update and handle the result with your own UI.

```dart
import 'package:firebase_app_update/firebase_app_update.dart';

final updateService = AppUpdateService();

Future<void> checkForUpdates() async {
  try {
    final result = await updateService.checkForUpdate();

    switch (result.type) {
      case UpdateType.none:
        print('The app is up to date.');
        break;

      case UpdateType.soft:
        print('An optional update is available.');
        print(result.message);
        break;

      case UpdateType.force:
        print('A mandatory update is required.');
        print(result.message);
        break;
    }

    if (result.hasUpdate) {
      print('Latest version: ${result.version}');
      print('Store URL: ${result.storeUrl}');
    }
  } on UpdateCheckException catch (error) {
    print('Unable to check for updates: $error');
  }
}
```

### 2. Show the built-in update dialog

Use `UpdateManager` to check for updates and display the package's built-in dialog.

```dart
import 'package:firebase_app_update/firebase_app_update.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final UpdateManager _updateManager;

  @override
  void initState() {
    super.initState();
    _updateManager = UpdateManager();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkForUpdate();
      }
    });
  }

  Future<void> _checkForUpdate() async {
    await _updateManager.checkAndShowUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to my app'),
      ),
    );
  }
}
```

Dialog behavior:

- **No update:** No dialog is displayed by default.
- **Soft update:** The user can dismiss the dialog and continue using the app.
- **Force update:** Normal dialog dismissal is prevented, and the user is prompted to update.

To display a message when the app is up to date or when an update check fails, use:

```dart
await _updateManager.checkAndShowUpdate(
  context,
  showUpToDateMessage: true,
  showErrorMessage: true,
);
```

Call this method with a valid `BuildContext` after the widget has been mounted.

### 3. Customize Remote Config keys

If your Firebase Remote Config parameters use different names, customize them through `UpdateConfig`:

```dart
final config = UpdateConfig(
  androidMinVersionKey: 'my_android_min_version',
  androidLatestVersionKey: 'my_android_latest_version',
  androidForceUpdateKey: 'my_android_force_update',
  androidUpdateMessageKey: 'my_android_update_message',
  androidStoreUrlKey: 'my_android_store_url',
  iosMinVersionKey: 'my_ios_min_version',
  iosLatestVersionKey: 'my_ios_latest_version',
  iosForceUpdateKey: 'my_ios_force_update',
  iosUpdateMessageKey: 'my_ios_update_message',
  iosStoreUrlKey: 'my_ios_store_url',
);

final updateService = AppUpdateService(config: config);
```

The parameter names in Firebase Console must match the keys configured in your application.

### 4. Configure Remote Config fetching

Customize the fetch timeout and minimum fetch interval:

```dart
final config = UpdateConfig(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: const Duration(hours: 1),
);

final updateService = AppUpdateService(config: config);
```

During development, you may use a shorter fetch interval to test configuration changes. Choose a suitable interval for production.

The service attempts to use activated Remote Config values if fetching fails. Handle `UpdateCheckException` in your application so update-check failures do not unexpectedly interrupt your user experience.

## API reference

### `AppUpdateService`

Checks the installed application version against Firebase Remote Config.

- `checkForUpdate()` — returns an `UpdateResult`.
- `UpdateCheckException` — represents an update-check failure.

### `UpdateManager`

Provides the built-in update dialog flow.

- `checkAndShowUpdate(context)` — checks for an update and displays the appropriate UI.

### `UpdateResult`

Contains the outcome of an update check.

| Property | Description |
|---|---|
| `type` | `UpdateType.none`, `UpdateType.soft`, or `UpdateType.force` |
| `message` | Update message from Remote Config |
| `version` | Configured latest version |
| `storeUrl` | Configured store URL |
| `hasUpdate` | Whether an update is available |
| `isForceUpdate` | Whether the update is mandatory |

### `UpdateType`

The possible update outcomes:

- `UpdateType.none` — no update is required.
- `UpdateType.soft` — an optional update is available.
- `UpdateType.force` — an update is mandatory according to the configured rules.

### `VersionUtils`

Provides semantic version validation and comparison utilities.

## Important notes

- This package checks versions, presents update prompts, and opens store links. It does not download or install updates directly.
- Configure a valid store URL for each supported platform.
- The force-update dialog prevents normal dismissal but cannot guarantee that a user will update or prevent every way of leaving or terminating the app.
- Test Remote Config values and store links on actual Android and iOS builds before releasing.
- Check the package's supported platforms and dependency requirements before using it on web or desktop.

## Troubleshooting

### The update check fails

Verify that Firebase is initialized, Remote Config is enabled, and the app has network access. Catch `UpdateCheckException` and provide appropriate fallback behavior.

### The update dialog does not appear

Confirm that the installed version is below the configured latest version and that your Remote Config changes have been published. If the app is already up to date, no update dialog is expected by default.

### The wrong update type is returned

Check the platform-specific `min_version`, `latest_version`, and `force_update` values. Ensure the minimum version does not exceed the latest version.

### The store does not open

Verify that the configured store URL points to the correct app listing and can be opened on the target device.

## Contributing

Bug reports, feature requests, and contributions are welcome. Please open an issue in the project's repository and include reproduction steps, relevant Flutter and Dart versions, and any error messages.

## License

See the `LICENSE` file in this repository.
