import 'dart:io';

import 'package:flutter_system_manager/core/platform/native_process_runner.dart';
import 'package:flutter_system_manager/core/platform/system_service.dart';
import 'package:flutter_system_manager/core/platform/windows_system_service.dart';
import 'package:flutter_system_manager/features/commands/data/predefined_commands.dart';
import 'package:flutter_system_manager/features/commands/domain/system_command.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNativeProcessRunner implements NativeProcessRunner {
  FakeNativeProcessRunner(this.result);

  final ProcessResult result;
  var callCount = 0;

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    required Duration timeout,
  }) async {
    callCount++;
    return result;
  }
}

void main() {
  group('WindowsSystemService', () {
    test('maps structured PowerShell output into SystemInfo', () async {
      final runner = FakeNativeProcessRunner(
        ProcessResult(
          1,
          0,
          '''{"operatingSystem":"Windows 11 Pro","version":"10.0","computerName":"DEV-PC","currentUser":"DEV-PC\\\\alex","architecture":"AMD64","processor":"Test CPU","totalMemoryBytes":16000000000,"availableMemoryBytes":8000000000}''',
          '',
        ),
      );
      final service = WindowsSystemService(processRunner: runner);

      final info = await service.getSystemInfo();

      expect(info.operatingSystem, 'Windows 11 Pro');
      expect(info.computerName, 'DEV-PC');
      expect(info.memoryUsage, 0.5);
      expect(runner.callCount, 1);
    });

    test('executes a command from the application allowlist', () async {
      final runner = FakeNativeProcessRunner(
        ProcessResult(1, 0, r'DEV-PC\alex', ''),
      );
      final service = WindowsSystemService(processRunner: runner);

      final result = await service.runCommand(PredefinedCommands.values.first);

      expect(result.isSuccess, isTrue);
      expect(result.stdout, r'DEV-PC\alex');
      expect(runner.callCount, 1);
    });

    test('rejects commands outside the application allowlist', () async {
      final runner = FakeNativeProcessRunner(ProcessResult(1, 0, '', ''));
      final service = WindowsSystemService(processRunner: runner);
      final unsafeCommand = SystemCommand(
        id: 'arbitrary',
        title: 'Arbitrary command',
        description: 'Not registered by the application.',
        executable: 'powershell.exe',
        arguments: const ['-Command', 'Remove-Item example'],
      );

      await expectLater(
        service.runCommand(unsafeCommand),
        throwsA(
          isA<SystemServiceException>().having(
            (error) => error.message,
            'message',
            contains('Only commands predefined'),
          ),
        ),
      );
      expect(runner.callCount, 0);
    });
  });
}
