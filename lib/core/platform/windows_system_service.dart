import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../features/commands/data/predefined_commands.dart';
import '../../features/commands/domain/command_result.dart';
import '../../features/commands/domain/system_command.dart';
import '../../features/processes/domain/system_process.dart';
import '../../features/services/domain/windows_service.dart';
import '../../features/system/domain/system_info.dart';
import 'native_process_runner.dart';
import 'system_service.dart';

class WindowsSystemService implements SystemService {
  WindowsSystemService({NativeProcessRunner? processRunner})
    : _processRunner = processRunner ?? const IoNativeProcessRunner();

  final NativeProcessRunner _processRunner;

  static const _queryTimeout = Duration(seconds: 20);
  static const _commandTimeout = Duration(seconds: 30);

  @override
  Future<SystemInfo> getSystemInfo() async {
    const script = r'''
$ErrorActionPreference = 'Stop'
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
[PSCustomObject]@{
  operatingSystem = $os.Caption
  version = "$($os.Version) (Build $($os.BuildNumber))"
  computerName = $env:COMPUTERNAME
  currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  architecture = $env:PROCESSOR_ARCHITECTURE
  processor = $cpu.Name
  totalMemoryBytes = [int64]$os.TotalVisibleMemorySize * 1KB
  availableMemoryBytes = [int64]$os.FreePhysicalMemory * 1KB
} | ConvertTo-Json -Compress
''';

    final decoded = await _runPowerShellJson(script);
    if (decoded is! Map<String, dynamic>) {
      throw const SystemServiceException(
        'Windows returned an unexpected system information response.',
      );
    }

    try {
      return SystemInfo.fromJson(decoded);
    } on FormatException catch (error) {
      throw SystemServiceException(
        'Could not read Windows system information: ${error.message}',
      );
    }
  }

  @override
  Future<List<SystemProcess>> getProcesses() async {
    const script = r'''
$ErrorActionPreference = 'Stop'
@(Get-Process | ForEach-Object {
  [PSCustomObject]@{
    id = $_.Id
    name = $_.ProcessName
    cpuSeconds = if ($null -eq $_.CPU) { $null } else { [math]::Round($_.CPU, 2) }
  }
} | Sort-Object name, id) | ConvertTo-Json -Compress
''';

    final decoded = await _runPowerShellJson(script);
    try {
      return _asJsonList(decoded)
          .map(SystemProcess.fromJson)
          .toList(growable: false);
    } on FormatException catch (error) {
      throw SystemServiceException(
        'Could not read the Windows process list: ${error.message}',
      );
    }
  }

  @override
  Future<List<WindowsService>> getServices() async {
    const script = r'''
$ErrorActionPreference = 'Stop'
@(Get-Service | ForEach-Object {
  [PSCustomObject]@{
    name = $_.Name
    displayName = $_.DisplayName
    status = $_.Status.ToString()
  }
} | Sort-Object displayName) | ConvertTo-Json -Compress
''';

    final decoded = await _runPowerShellJson(script);
    try {
      return _asJsonList(decoded)
          .map(WindowsService.fromJson)
          .toList(growable: false);
    } on FormatException catch (error) {
      throw SystemServiceException(
        'Could not read the Windows service list: ${error.message}',
      );
    }
  }

  @override
  Future<CommandResult> runCommand(SystemCommand command) async {
    if (!PredefinedCommands.contains(command)) {
      throw const SystemServiceException(
        'Only commands predefined by the application can be executed.',
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final result = await _processRunner.run(
        command.executable,
        command.arguments,
        timeout: _commandTimeout,
      );
      stopwatch.stop();
      return CommandResult(
        exitCode: result.exitCode,
        stdout: result.stdout.toString().trimRight(),
        stderr: result.stderr.toString().trimRight(),
        duration: stopwatch.elapsed,
      );
    } on TimeoutException {
      throw const SystemServiceException(
        'The command exceeded the 30 second time limit.',
      );
    } on ProcessException catch (error) {
      throw SystemServiceException(
        'Windows could not start ${command.executable}: ${error.message}',
      );
    }
  }

  Future<dynamic> _runPowerShellJson(String script) async {
    ProcessResult result;
    try {
      result = await _processRunner.run('powershell.exe', [
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ], timeout: _queryTimeout);
    } on TimeoutException {
      throw const SystemServiceException(
        'Windows did not respond within 20 seconds.',
      );
    } on ProcessException catch (error) {
      throw SystemServiceException(
        'PowerShell could not be started: ${error.message}',
      );
    }

    if (result.exitCode != 0) {
      final details = result.stderr.toString().trim();
      throw SystemServiceException(
        details.isEmpty
            ? 'PowerShell exited with code ${result.exitCode}.'
            : 'PowerShell failed: $details',
      );
    }

    final output = result.stdout.toString().trim().replaceFirst('\uFEFF', '');
    if (output.isEmpty) {
      throw const SystemServiceException('PowerShell returned no data.');
    }

    try {
      return jsonDecode(output);
    } on FormatException {
      throw const SystemServiceException(
        'PowerShell returned data in an unexpected format.',
      );
    }
  }

  static List<Map<String, dynamic>> _asJsonList(dynamic decoded) {
    final values = decoded is List ? decoded : [decoded];
    return values
        .map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Expected a JSON object.');
          }
          return value;
        })
        .toList(growable: false);
  }
}
