import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'update_config.dart';
import 'update_result.dart';
import 'version_utils.dart';

class UpdateCheckException implements Exception {
  final String message;
  final Object? cause;

  const UpdateCheckException(this.message, {this.cause});

  @override
  String toString() => 'UpdateCheckException: $message';
}

class AppUpdateService {
  final FirebaseRemoteConfig _remoteConfig;
  final UpdateConfig _config;
  final Future<PackageInfo> Function() _packageInfoProvider;

  AppUpdateService({
    FirebaseRemoteConfig? remoteConfig,
    UpdateConfig config = const UpdateConfig(),
    Future<PackageInfo> Function()? packageInfoProvider,
  }) : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance,
       _config = config,
       _packageInfoProvider = packageInfoProvider ?? PackageInfo.fromPlatform;

  Future<UpdateResult> checkForUpdate() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _config.fetchTimeout,
          minimumFetchInterval: _config.minimumFetchInterval,
        ),
      );

      // If fetching fails, try the already activated cached values.
      try {
        await _remoteConfig.fetchAndActivate();
      } catch (_) {
        // Cached configuration may still be usable offline.
      }

      final packageInfo = await _packageInfoProvider();
      final currentVersion = packageInfo.version;

      final platform = _getPlatformConfig();

      final minVersion = _remoteConfig.getString(platform.minVersionKey).trim();
      final latestVersion = _remoteConfig
          .getString(platform.latestVersionKey)
          .trim();
      final forceUpdate = _remoteConfig.getBool(platform.forceUpdateKey);
      final message = _remoteConfig.getString(platform.updateMessageKey);
      final storeUrl = _remoteConfig.getString(platform.storeUrlKey).trim();

      if (!VersionUtils.isValid(currentVersion)) {
        throw UpdateCheckException(
          'The installed app version is invalid: $currentVersion',
        );
      }

      if (!VersionUtils.isValid(minVersion) ||
          !VersionUtils.isValid(latestVersion)) {
        throw UpdateCheckException(
          'Remote Config must contain valid minimum and latest versions.',
        );
      }

      if (VersionUtils.compare(minVersion, latestVersion) > 0) {
        throw const UpdateCheckException(
          'Minimum supported version cannot exceed latest version.',
        );
      }

      // No update is needed if the installed version is current.
      if (!VersionUtils.isLower(currentVersion, latestVersion)) {
        return UpdateResult(
          type: UpdateType.none,
          message: '',
          version: latestVersion,
          storeUrl: storeUrl,
        );
      }

      // Below the minimum version: always require an update.
      // The force flag can also make newer versions mandatory.
      final mustUpdate =
          VersionUtils.isLower(currentVersion, minVersion) || forceUpdate;

      return UpdateResult(
        type: mustUpdate ? UpdateType.force : UpdateType.soft,
        message: message,
        version: latestVersion,
        storeUrl: storeUrl,
      );
    } on UpdateCheckException {
      rethrow;
    } catch (e) {
      throw UpdateCheckException('Unable to check for app updates.', cause: e);
    }
  }

  _PlatformConfig _getPlatformConfig() {
    if (Platform.isAndroid) {
      return _PlatformConfig(
        minVersionKey: _config.androidMinVersionKey,
        latestVersionKey: _config.androidLatestVersionKey,
        forceUpdateKey: _config.androidForceUpdateKey,
        updateMessageKey: _config.androidUpdateMessageKey,
        storeUrlKey: _config.androidStoreUrlKey,
      );
    }

    if (Platform.isIOS) {
      return _PlatformConfig(
        minVersionKey: _config.iosMinVersionKey,
        latestVersionKey: _config.iosLatestVersionKey,
        forceUpdateKey: _config.iosForceUpdateKey,
        updateMessageKey: _config.iosUpdateMessageKey,
        storeUrlKey: _config.iosStoreUrlKey,
      );
    }

    throw const UpdateCheckException(
      'App updates are supported only on Android and iOS.',
    );
  }
}

class _PlatformConfig {
  final String minVersionKey;
  final String latestVersionKey;
  final String forceUpdateKey;
  final String updateMessageKey;
  final String storeUrlKey;

  const _PlatformConfig({
    required this.minVersionKey,
    required this.latestVersionKey,
    required this.forceUpdateKey,
    required this.updateMessageKey,
    required this.storeUrlKey,
  });
}
