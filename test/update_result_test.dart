import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_app_update/firebase_app_update.dart';

void main() {
  test('identifies mandatory updates', () {
    const result = UpdateResult(
      type: UpdateType.force,
      message: 'Please update.',
      version: '2.0.0',
      storeUrl: 'https://example.com',
    );

    expect(result.hasUpdate, isTrue);
    expect(result.isForceUpdate, isTrue);
  });

  test('identifies no update required', () {
    const result = UpdateResult(
      type: UpdateType.none,
      message: '',
      version: '1.0.0',
      storeUrl: '',
    );

    expect(result.hasUpdate, isFalse);
    expect(result.isForceUpdate, isFalse);
  });
}
