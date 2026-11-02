import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_app_update/firebase_app_update.dart';

void main() {
  group('VersionUtils', () {
    test('compares numeric version components correctly', () {
      expect(VersionUtils.isLower('1.9.0', '1.10.0'), isTrue);
      expect(VersionUtils.isLower('1.2.0', '1.2.1'), isTrue);
      expect(VersionUtils.isLower('2.0.0', '1.9.9'), isFalse);
    });

    test('handles prerelease versions', () {
      expect(VersionUtils.isLower('2.0.0-beta.1', '2.0.0'), isTrue);
      expect(VersionUtils.compare('2.0.0', '2.0.0'), 0);
    });

    test('ignores build metadata', () {
      expect(VersionUtils.compare('1.0.0+1', '1.0.0+2'), 0);
    });

    test('rejects malformed versions', () {
      expect(VersionUtils.isValid('1.0'), isFalse);
      expect(
        () => VersionUtils.compare('invalid', '1.0.0'),
        throwsFormatException,
      );
    });
  });
}
