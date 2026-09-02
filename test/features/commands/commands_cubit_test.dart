import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_system_manager/core/platform/system_service.dart';
import 'package:flutter_system_manager/features/commands/data/predefined_commands.dart';
import 'package:flutter_system_manager/features/commands/domain/command_result.dart';
import 'package:flutter_system_manager/features/commands/presentation/cubit/commands_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSystemService extends Mock implements SystemService {}

void main() {
  late MockSystemService service;

  setUp(() => service = MockSystemService());

  blocTest<CommandsCubit, CommandsState>(
    'executes the selected predefined command through SystemService',
    build: () {
      final command = PredefinedCommands.values.first;
      when(() => service.runCommand(command)).thenAnswer(
        (_) async => const CommandResult(
          exitCode: 0,
          stdout: 'desktop-user',
          stderr: '',
          duration: Duration(milliseconds: 20),
        ),
      );
      return CommandsCubit(service);
    },
    act: (cubit) => cubit.run(),
    expect: () => [
      isA<CommandsRunning>(),
      isA<CommandsCompleted>()
          .having((state) => state.result.stdout, 'stdout', 'desktop-user')
          .having((state) => state.result.isSuccess, 'isSuccess', isTrue),
    ],
    verify: (_) {
      verify(() => service.runCommand(PredefinedCommands.values.first))
          .called(1);
    },
  );
}
