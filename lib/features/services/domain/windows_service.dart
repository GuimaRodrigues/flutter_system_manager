class WindowsService {
  const WindowsService({
    required this.name,
    required this.displayName,
    required this.status,
  });

  factory WindowsService.fromJson(Map<String, dynamic> json) {
    return WindowsService(
      name: json['name']?.toString().trim() ?? '',
      displayName: json['displayName']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? 'Unknown',
    );
  }

  final String name;
  final String displayName;
  final String status;

  bool get isRunning => status.toLowerCase() == 'running';
}
