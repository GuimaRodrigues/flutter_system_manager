import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_panels.dart';
import '../../domain/system_process.dart';
import '../cubit/processes_cubit.dart';

class ProcessesPage extends StatelessWidget {
  const ProcessesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcessesCubit, ProcessesState>(
      builder: (context, state) {
        final loading = state is ProcessesLoading || state is ProcessesInitial;
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              PageHeader(
                title: 'Running processes',
                subtitle: 'Read-only process data reported by Get-Process.',
                action: FilledButton.icon(
                  onPressed: loading
                      ? null
                      : context.read<ProcessesCubit>().load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: switch (state) {
                  ProcessesLoaded(:final processes) => _ProcessesTable(
                    processes: processes,
                  ),
                  ProcessesFailure(:final message) => ErrorPanel(
                    message: message,
                    onRetry: context.read<ProcessesCubit>().load,
                  ),
                  _ => const LoadingPanel(label: 'Reading running processes…'),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProcessesTable extends StatelessWidget {
  const _ProcessesTable({required this.processes});

  final List<SystemProcess> processes;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _TableHeader(count: processes.length),
          const Divider(height: 1),
          if (processes.isEmpty)
            const Expanded(child: Center(child: Text('No processes found.')))
          else
            Expanded(
              child: ListView.separated(
                itemCount: processes.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final process = processes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            process.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(flex: 2, child: Text(process.id.toString())),
                        Expanded(
                          flex: 2,
                          child: Text(
                            process.cpuSeconds == null
                                ? 'Unavailable'
                                : '${process.cpuSeconds!.toStringAsFixed(2)} s',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w700);
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text('PROCESS ($count)', style: style)),
          Expanded(flex: 2, child: Text('PID', style: style)),
          Expanded(flex: 2, child: Text('CPU TIME', style: style)),
        ],
      ),
    );
  }
}
