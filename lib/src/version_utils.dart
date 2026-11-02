class VersionUtils {
  VersionUtils._();

  static final RegExp _pattern = RegExp(
    r'^v?(0|[1-9]\d*)'
    r'\.(0|[1-9]\d*)'
    r'\.(0|[1-9]\d*)'
    r'(?:-([0-9A-Za-z.-]+))?'
    r'(?:\+[0-9A-Za-z.-]+)?$',
  );

  static bool isValid(String version) {
    return _pattern.hasMatch(version.trim());
  }

  /// Returns a negative number if [a] is older than [b],
  /// zero if equal, and a positive number if newer.
  static int compare(String a, String b) {
    final matchA = _pattern.firstMatch(a.trim());
    final matchB = _pattern.firstMatch(b.trim());

    if (matchA == null || matchB == null) {
      throw FormatException('Invalid semantic version: $a or $b');
    }

    for (var i = 1; i <= 3; i++) {
      final partA = int.parse(matchA.group(i)!);
      final partB = int.parse(matchB.group(i)!);

      if (partA != partB) {
        return partA.compareTo(partB);
      }
    }

    final preA = matchA.group(4);
    final preB = matchB.group(4);

    // A release is newer than its prerelease.
    if (preA == null && preB == null) return 0;
    if (preA == null) return 1;
    if (preB == null) return -1;

    final partsA = preA.split('.');
    final partsB = preB.split('.');

    for (var i = 0; i < partsA.length && i < partsB.length; i++) {
      final x = partsA[i];
      final y = partsB[i];

      if (x == y) continue;

      final nx = int.tryParse(x);
      final ny = int.tryParse(y);

      if (nx != null && ny != null) {
        return nx.compareTo(ny);
      }

      // Numeric prerelease identifiers have lower precedence
      // than nonnumeric identifiers.
      if (nx != null) return -1;
      if (ny != null) return 1;

      return x.compareTo(y);
    }

    return partsA.length.compareTo(partsB.length);
  }

  static bool isLower(String current, String target) {
    return compare(current, target) < 0;
  }
}
