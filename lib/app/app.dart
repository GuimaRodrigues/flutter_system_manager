import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/public_ip_client.dart';
import '../core/platform/system_service.dart';
import '../core/platform/windows_system_service.dart';
import '../features/commands/presentation/cubit/commands_cubit.dart';
import '../features/network/presentation/cubit/public_ip_cubit.dart';
import '../features/processes/presentation/cubit/processes_cubit.dart';
import '../features/services/presentation/cubit/services_cubit.dart';
import '../features/system/presentation/cubit/system_cubit.dart';
import 'app_shell.dart';

class FlutterSystemManagerApp extends StatefulWidget {
  const FlutterSystemManagerApp({
    super.key,
    this.systemService,
    this.publicIpService,
    this.isWindows,
  });

  final SystemService? systemService;
  final PublicIpService? publicIpService;
  final bool? isWindows;

  @override
  State<FlutterSystemManagerApp> createState() =>
      _FlutterSystemManagerAppState();
}

class _FlutterSystemManagerAppState extends State<FlutterSystemManagerApp> {
  late final bool _isSupported;
  SystemService? _systemService;
  PublicIpService? _publicIpService;
  PublicIpClient? _ownedPublicIpClient;

  @override
  void initState() {
    super.initState();
    _isSupported = widget.isWindows ?? Platform.isWindows;
    if (_isSupported) {
      _systemService = widget.systemService ?? WindowsSystemService();
      if (widget.publicIpService == null) {
        _ownedPublicIpClient = PublicIpClient();
      }
      _publicIpService = widget.publicIpService ?? _ownedPublicIpClient;
    }
  }

  @override
  void dispose() {
    _ownedPublicIpClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter System Manager',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: _isSupported
          ? MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => SystemCubit(_systemService!)..load(),
                ),
                BlocProvider(
                  create: (_) => ProcessesCubit(_systemService!)..load(),
                ),
                BlocProvider(
                  create: (_) => ServicesCubit(_systemService!)..load(),
                ),
                BlocProvider(create: (_) => CommandsCubit(_systemService!)),
                BlocProvider(
                  create: (_) => PublicIpCubit(_publicIpService!)..load(),
                ),
              ],
              child: const AppShell(),
            )
          : const UnsupportedPlatformView(),
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF2563EB);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFF8FAFC),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      fontFamily: 'Segoe UI',
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0)),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class UnsupportedPlatformView extends StatelessWidget {
  const UnsupportedPlatformView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.desktop_windows_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Windows required',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This demo currently supports Windows system integration. '
                    'The platform boundary is designed so other implementations '
                    'can be added later.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
