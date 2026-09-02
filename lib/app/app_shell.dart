import 'package:flutter/material.dart';

import '../features/commands/presentation/pages/commands_page.dart';
import '../features/processes/presentation/pages/processes_page.dart';
import '../features/services/presentation/pages/services_page.dart';
import '../features/system/presentation/pages/system_overview_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 0;

  static const _pages = [
    SystemOverviewPage(),
    ProcessesPage(),
    ServicesPage(),
    CommandsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final extended = constraints.maxWidth >= 1120;
          return Row(
            children: [
              NavigationRail(
                extended: extended,
                minExtendedWidth: 224,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                leading: Padding(
                  padding: EdgeInsets.fromLTRB(
                    extended ? 18 : 8,
                    18,
                    extended ? 18 : 8,
                    24,
                  ),
                  child: extended
                      ? const _ExpandedBrand()
                      : const _CompactBrand(),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    selectedIcon: Icon(Icons.space_dashboard),
                    label: Text('Overview'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.memory_outlined),
                    selectedIcon: Icon(Icons.memory),
                    label: Text('Processes'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Services'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.terminal_outlined),
                    selectedIcon: Icon(Icons.terminal),
                    label: Text('Commands'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: _pages),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.monitor_heart_outlined, color: Colors.white),
    );
  }
}

class _ExpandedBrand extends StatelessWidget {
  const _ExpandedBrand();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 188,
      child: Row(
        children: [
          const _CompactBrand(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'System Manager',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
