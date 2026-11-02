class UpdateConfig {
  final Duration fetchTimeout;
  final Duration minimumFetchInterval;

  final String androidMinVersionKey;
  final String androidLatestVersionKey;
  final String androidForceUpdateKey;
  final String androidUpdateMessageKey;
  final String androidStoreUrlKey;

  final String iosMinVersionKey;
  final String iosLatestVersionKey;
  final String iosForceUpdateKey;
  final String iosUpdateMessageKey;
  final String iosStoreUrlKey;

  const UpdateConfig({
    this.fetchTimeout = const Duration(seconds: 10),
    this.minimumFetchInterval = const Duration(hours: 1),
    this.androidMinVersionKey = 'android_min_version',
    this.androidLatestVersionKey = 'android_latest_version',
    this.androidForceUpdateKey = 'android_force_update',
    this.androidUpdateMessageKey = 'android_update_message',
    this.androidStoreUrlKey = 'android_store_url',
    this.iosMinVersionKey = 'ios_min_version',
    this.iosLatestVersionKey = 'ios_latest_version',
    this.iosForceUpdateKey = 'ios_force_update',
    this.iosUpdateMessageKey = 'ios_update_message',
    this.iosStoreUrlKey = 'ios_store_url',
  });
}
