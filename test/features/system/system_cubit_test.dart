import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_system_manager/core/platform/system_service.dart';
import 'package:flutter_system_manager/features/system/domain/system_info.dart';
import 'package:flutter_system_manager/features/system/presentation/cubit/system_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSystemService extends Mock implements SystemService {}

void main() {
  late MockSystemService service;

  const info = SystemInfo(
    operatingSystem: 'Windows 11 Pro',
    version: '10.0',
    computerName: 'TEST-PC',
    currentUser: r'TEST-PC\tester',
    architecture: 'AMD64',
    processor: 'Test CPU',
    totalMemoryBytes: 16000000000,
    availableMemoryBytes: 8000000000,
  );

  setUp(() => service = MockSystemService());

  blocTest<SystemCubit, SystemState>(
    'emits loading then loaded when the service succeeds',
    build: () {
      when(() => service.getSystemInfo()).thenAnswer((_) async => info);
      return SystemCubit(service);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<SystemLoading>(),
      isA<SystemLoaded>().having((state) => state.info, 'info', same(info)),
    ],
    verify: (_) => verify(() => service.getSystemInfo()).called(1),
  );

  blocTest<SystemCubit, SystemState>(
    'emits loading then failure when the service throws',
    build: () {
      when(
        () => service.getSystemInfo(),
      ).thenThrow(const SystemServiceException('PowerShell is unavailable.'));
      return SystemCubit(service);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<SystemLoading>(),
      isA<SystemFailure>().having(
        (state) => state.message,
        'message',
        'PowerShell is unavailable.',
      ),
    ],
  );
}
