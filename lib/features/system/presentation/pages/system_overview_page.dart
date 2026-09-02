import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_panels.dart';
import '../../../network/presentation/cubit/public_ip_cubit.dart';
import '../../domain/system_info.dart';
import '../cubit/system_cubit.dart';

class SystemOverviewPage extends StatelessWidget {
  const SystemOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemCubit, SystemState>(
      builder: (context, state) {
        final loading = state is SystemLoading || state is SystemInitial;
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'System overview',
                subtitle: 'Live details reported by this Windows machine.',
                action: FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () {
                          context.read<SystemCubit>().load();
                          context.read<PublicIpCubit>().load();
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _SystemStateBody(state: state)),
            ],
          ),
        );
      },
    );
  }
}

class _SystemStateBody extends StatelessWidget {
  const _SystemStateBody({required this.state});

  final SystemState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      SystemLoaded(:final info) => _OverviewContent(info: info),
      SystemFailure(:final message) => ErrorPanel(
        message: message,
        onRetry: context.read<SystemCubit>().load,
      ),
      _ => const LoadingPanel(label: 'Reading Windows system information…'),
    };
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.info});

  final SystemInfo info;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 2 : 1;
          final itemWidth = columns == 2
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _InfoCard(
                    width: itemWidth,
                    icon: Icons.laptop_windows_outlined,
                    label: 'Operating system',
                    value: info.operatingSystem,
                    detail: info.version,
                  ),
                  _InfoCard(
                    width: itemWidth,
                    icon: Icons.computer_outlined,
                    label: 'Computer',
                    value: info.computerName,
                    detail: info.currentUser,
                  ),
                  _InfoCard(
                    width: itemWidth,
                    icon: Icons.developer_board_outlined,
                    label: 'Processor',
                    value: info.processor,
                    detail: info.architecture,
                  ),
                  _MemoryCard(width: itemWidth, info: info),
                ],
              ),
              const SizedBox(height: 16),
              const _PublicIpCard(),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 146,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardIcon(icon: icon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value.isEmpty ? 'Unavailable' : value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      detail.isEmpty ? 'No additional details' : detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.width, required this.info});

  final double width;
  final SystemInfo info;

  @override
  Widget build(BuildContext context) {
    final usedPercent = (info.memoryUsage * 100).round();
    return SizedBox(
      width: width,
      height: 146,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardIcon(icon: Icons.memory_outlined),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEMORY',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$usedPercent% in use',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: info.memoryUsage,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const Spacer(),
                    Text(
                      '${formatBytes(info.availableMemoryBytes)} available of '
                      '${formatBytes(info.totalMemoryBytes)}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _PublicIpCard extends StatelessWidget {
  const _PublicIpCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Row(
          children: [
            const _CardIcon(icon: Icons.public_outlined),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PUBLIC IP',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  BlocBuilder<PublicIpCubit, PublicIpState>(
                    builder: (context, state) {
                      return switch (state) {
                        PublicIpLoaded(:final publicIp) => Text.rich(
                          TextSpan(
                            text: publicIp.address,
                            children: [
                              TextSpan(
                                text: '  ·  Source: ${publicIp.source}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        PublicIpFailure(:final message) => Row(
                          children: [
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: context.read<PublicIpCubit>().load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                        _ => const LinearProgressIndicator(),
                      };
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
