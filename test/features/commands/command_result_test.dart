import 'package:flutter_system_manager/features/commands/domain/command_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandResult', () {
    test('is successful only for exit code zero', () {
      const success = CommandResult(
        exitCode: 0,
        stdout: 'done',
        stderr: '',
        duration: Duration(milliseconds: 12),
      );
      const failure = CommandResult(
        exitCode: 1,
        stdout: '',
        stderr: 'failed',
        duration: Duration(milliseconds: 8),
      );

      expect(success.isSuccess, isTrue);
      expect(failure.isSuccess, isFalse);
    });
  });
}
