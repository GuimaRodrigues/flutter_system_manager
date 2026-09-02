import '../../features/commands/domain/command_result.dart';
import '../../features/commands/domain/system_command.dart';
import '../../features/processes/domain/system_process.dart';
import '../../features/services/domain/windows_service.dart';
import '../../features/system/domain/system_info.dart';

abstract interface class SystemService {
  Future<SystemInfo> getSystemInfo();

  Future<List<SystemProcess>> getProcesses();

  Future<List<WindowsService>> getServices();

  Future<CommandResult> runCommand(SystemCommand command);
}

class SystemServiceException implements Exception {
  const SystemServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
