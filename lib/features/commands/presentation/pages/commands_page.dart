import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/page_header.dart';
import '../../data/predefined_commands.dart';
import '../../domain/command_result.dart';
import '../cubit/commands_cubit.dart';

class CommandsPage extends StatelessWidget {
  const CommandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const PageHeader(
            title: 'Command runner',
            subtitle: 'Execute a controlled set of safe, predefined commands.',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<CommandsCubit, CommandsState>(
              builder: (context, state) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 850) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 320,
                            child: _CommandList(state: state),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _CommandOutput(state: state)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: _CommandList(state: state),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _CommandOutput(state: state)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandList extends StatelessWidget {
  const _CommandList({required this.state});

  final CommandsState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: PredefinedCommands.values.length,
        separatorBuilder: (_, _) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final command = PredefinedCommands.values[index];
          final selected = command.id == state.command.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListTile(
              selected: selected,
              selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(_iconFor(command.id)),
              title: Text(
                command.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                command.executable,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: state is CommandsRunning
                  ? null
                  : () => context.read<CommandsCubit>().select(command),
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(String id) {
    return switch (id) {
      'current-user' => Icons.person_outline,
      'windows-version' => Icons.window_outlined,
      'ip-configuration' => Icons.lan_outlined,
      'network-adapters' => Icons.router_outlined,
      _ => Icons.storage_outlined,
    };
  }
}

class _CommandOutput extends StatelessWidget {
  const _CommandOutput({required this.state});

  final CommandsState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.command.title,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        state.command.description,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: state is CommandsRunning
                      ? null
                      : context.read<CommandsCubit>().run,
                  icon: state is CommandsRunning
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    state is CommandsRunning ? 'Running' : 'Run command',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _OutputBody(state: state)),
        ],
      ),
    );
  }
}

class _OutputBody extends StatelessWidget {
  const _OutputBody({required this.state});

  final CommandsState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CommandsRunning() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Waiting for Windows…'),
          ],
        ),
      ),
      CommandsCompleted(:final result) => _ResultView(result: result),
      CommandsFailure(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      _ => const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Select a predefined command and run it to inspect its output.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      ),
    };
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final CommandResult result;

  @override
  Widget build(BuildContext context) {
    final statusColor = result.isSuccess
        ? const Color(0xFF047857)
        : Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              Text(
                result.isSuccess ? 'Completed' : 'Failed',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('Exit code ${result.exitCode}'),
              Text('${result.duration.inMilliseconds} ms'),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: SelectableText(
                _visibleOutput,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontFamily: 'Consolas',
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get _visibleOutput {
    final sections = <String>[];
    if (result.stdout.trim().isNotEmpty) sections.add(result.stdout);
    if (result.stderr.trim().isNotEmpty) {
      sections.add('STDERR\n${result.stderr}');
    }
    return sections.isEmpty
        ? '(Command produced no output.)'
        : sections.join('\n\n');
  }
}
