import '../domain/system_command.dart';

abstract final class PredefinedCommands {
  static final List<SystemCommand> values = List.unmodifiable([
    SystemCommand(
      id: 'current-user',
      title: 'Current user',
      description: 'Shows the Windows identity used by this application.',
      executable: 'whoami.exe',
      arguments: const [],
    ),
    SystemCommand(
      id: 'windows-version',
      title: 'Windows version',
      description:
          'Displays the installed Windows edition, version, and build.',
      executable: 'powershell.exe',
      arguments: const [
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber | Format-List | Out-String -Width 200',
      ],
    ),
    SystemCommand(
      id: 'ip-configuration',
      title: 'IP configuration',
      description: 'Displays local Windows network configuration.',
      executable: 'ipconfig.exe',
      arguments: const ['/all'],
    ),
    SystemCommand(
      id: 'network-adapters',
      title: 'Network adapters',
      description: 'Lists network adapters and their current link state.',
      executable: 'powershell.exe',
      arguments: const [
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed | Format-Table -AutoSize | Out-String -Width 240',
      ],
    ),
    SystemCommand(
      id: 'disk-information',
      title: 'Disk information',
      description: 'Shows local disks, free space, and total size.',
      executable: 'powershell.exe',
      arguments: const [
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'''Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, VolumeName, @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize | Out-String -Width 200''',
      ],
    ),
  ]);

  static bool contains(SystemCommand command) {
    return values.any(
      (allowed) =>
          allowed.id == command.id &&
          allowed.executable == command.executable &&
          _sameArguments(allowed.arguments, command.arguments),
    );
  }

  static bool _sameArguments(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
