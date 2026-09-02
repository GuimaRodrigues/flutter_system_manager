class SystemInfo {
  const SystemInfo({
    required this.operatingSystem,
    required this.version,
    required this.computerName,
    required this.currentUser,
    required this.architecture,
    required this.processor,
    required this.totalMemoryBytes,
    required this.availableMemoryBytes,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    final operatingSystem = _readString(json, 'operatingSystem');
    final totalMemoryBytes = _readInt(json, 'totalMemoryBytes');
    final availableMemoryBytes = _readInt(json, 'availableMemoryBytes');

    if (operatingSystem.isEmpty) {
      throw const FormatException('Operating system name is missing.');
    }
    if (totalMemoryBytes < 0 || availableMemoryBytes < 0) {
      throw const FormatException('Memory values cannot be negative.');
    }

    return SystemInfo(
      operatingSystem: operatingSystem,
      version: _readString(json, 'version'),
      computerName: _readString(json, 'computerName'),
      currentUser: _readString(json, 'currentUser'),
      architecture: _readString(json, 'architecture'),
      processor: _readString(json, 'processor'),
      totalMemoryBytes: totalMemoryBytes,
      availableMemoryBytes: availableMemoryBytes,
    );
  }

  final String operatingSystem;
  final String version;
  final String computerName;
  final String currentUser;
  final String architecture;
  final String processor;
  final int totalMemoryBytes;
  final int availableMemoryBytes;

  double get memoryUsage {
    if (totalMemoryBytes == 0) return 0;
    return (1 - (availableMemoryBytes / totalMemoryBytes)).clamp(0, 1);
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value == null ? '' : value.toString().trim();
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ??
        (throw FormatException('Invalid integer for $key.'));
  }
}
