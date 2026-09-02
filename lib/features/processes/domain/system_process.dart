class SystemProcess {
  const SystemProcess({required this.id, required this.name, this.cpuSeconds});

  factory SystemProcess.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final id = idValue is num
        ? idValue.toInt()
        : int.tryParse(idValue?.toString() ?? '');
    if (id == null) throw const FormatException('Process ID is invalid.');

    final cpuValue = json['cpuSeconds'];
    final cpuSeconds = cpuValue is num
        ? cpuValue.toDouble()
        : double.tryParse(cpuValue?.toString() ?? '');

    return SystemProcess(
      id: id,
      name: json['name']?.toString().trim() ?? 'Unknown process',
      cpuSeconds: cpuSeconds,
    );
  }

  final int id;
  final String name;
  final double? cpuSeconds;
}
