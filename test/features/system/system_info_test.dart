import 'package:flutter_system_manager/features/system/domain/system_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SystemInfo', () {
    test('maps structured PowerShell JSON into a typed model', () {
      final info = SystemInfo.fromJson({
        'operatingSystem': 'Microsoft Windows 11 Pro',
        'version': '10.0.26100 (Build 26100)',
        'computerName': 'DEV-PC',
        'currentUser': r'DEV-PC\alex',
        'architecture': 'AMD64',
        'processor': 'Example CPU',
        'totalMemoryBytes': 17179869184,
        'availableMemoryBytes': '8589934592',
      });

      expect(info.operatingSystem, 'Microsoft Windows 11 Pro');
      expect(info.computerName, 'DEV-PC');
      expect(info.totalMemoryBytes, 17179869184);
      expect(info.availableMemoryBytes, 8589934592);
      expect(info.memoryUsage, 0.5);
    });

    test('rejects invalid memory data', () {
      expect(
        () => SystemInfo.fromJson({
          'operatingSystem': 'Windows',
          'totalMemoryBytes': 'not-a-number',
          'availableMemoryBytes': 100,
        }),
        throwsFormatException,
      );
    });
  });
}
