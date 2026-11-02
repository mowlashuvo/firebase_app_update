enum UpdateType { none, soft, force }

class UpdateResult {
  final UpdateType type;
  final String message;
  final String version;
  final String storeUrl;

  const UpdateResult({
    required this.type,
    required this.message,
    required this.version,
    required this.storeUrl,
  });

  bool get hasUpdate => type != UpdateType.none;

  bool get isForceUpdate => type == UpdateType.force;
}
