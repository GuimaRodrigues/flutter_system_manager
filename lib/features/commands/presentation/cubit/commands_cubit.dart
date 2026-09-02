import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/platform/system_service.dart';
import '../../../../core/utils/error_message.dart';
import '../../data/predefined_commands.dart';
import '../../domain/command_result.dart';
import '../../domain/system_command.dart';

sealed class CommandsState {
  const CommandsState(this.command);

  final SystemCommand command;
}

final class CommandsReady extends CommandsState {
  const CommandsReady(super.command);
}

final class CommandsRunning extends CommandsState {
  const CommandsRunning(super.command);
}

final class CommandsCompleted extends CommandsState {
  const CommandsCompleted(super.command, this.result);

  final CommandResult result;
}

final class CommandsFailure extends CommandsState {
  const CommandsFailure(super.command, this.message);

  final String message;
}

class CommandsCubit extends Cubit<CommandsState> {
  CommandsCubit(this._service)
    : super(CommandsReady(PredefinedCommands.values.first));

  final SystemService _service;

  void select(SystemCommand command) {
    if (state is CommandsRunning || !PredefinedCommands.contains(command)) {
      return;
    }
    emit(CommandsReady(command));
  }

  Future<void> run() async {
    if (state is CommandsRunning) return;
    final command = state.command;
    emit(CommandsRunning(command));
    try {
      emit(CommandsCompleted(command, await _service.runCommand(command)));
    } catch (error) {
      emit(CommandsFailure(command, errorMessage(error)));
    }
  }
}
