import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_panels.dart';
import '../../domain/windows_service.dart';
import '../cubit/services_cubit.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        final loading = state is ServicesLoading || state is ServicesInitial;
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              PageHeader(
                title: 'Windows services',
                subtitle:
                    'A read-only view of services and their current state.',
                action: FilledButton.icon(
                  onPressed: loading
                      ? null
                      : context.read<ServicesCubit>().load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: switch (state) {
                  ServicesLoaded(:final services) => _ServicesTable(
                    services: services,
                  ),
                  ServicesFailure(:final message) => ErrorPanel(
                    message: message,
                    onRetry: context.read<ServicesCubit>().load,
                  ),
                  _ => const LoadingPanel(label: 'Reading Windows services…'),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServicesTable extends StatelessWidget {
  const _ServicesTable({required this.services});

  final List<WindowsService> services;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _TableHeader(count: services.length),
          const Divider(height: 1),
          if (services.isEmpty)
            const Expanded(child: Center(child: Text('No services found.')))
          else
            Expanded(
              child: ListView.separated(
                itemCount: services.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            service.displayName.isEmpty
                                ? service.name
                                : service.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            service.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _StatusChip(service: service),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.service});

  final WindowsService service;

  @override
  Widget build(BuildContext context) {
    final foreground = service.isRunning
        ? const Color(0xFF047857)
        : const Color(0xFF64748B);
    final background = service.isRunning
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFF1F5F9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        service.status,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
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
          Expanded(flex: 4, child: Text('DISPLAY NAME ($count)', style: style)),
          Expanded(flex: 3, child: Text('SERVICE NAME', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
        ],
      ),
    );
  }
}
