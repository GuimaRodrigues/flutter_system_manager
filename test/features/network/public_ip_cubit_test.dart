import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_system_manager/core/network/public_ip_client.dart';
import 'package:flutter_system_manager/features/network/presentation/cubit/public_ip_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPublicIpService extends Mock implements PublicIpService {}

void main() {
  late MockPublicIpService service;

  setUp(() => service = MockPublicIpService());

  blocTest<PublicIpCubit, PublicIpState>(
    'depends on the public IP abstraction and exposes typed data',
    build: () {
      when(() => service.fetch()).thenAnswer(
        (_) async => const PublicIp(address: '203.0.113.1', source: 'test'),
      );
      return PublicIpCubit(service);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<PublicIpLoading>(),
      isA<PublicIpLoaded>()
          .having((state) => state.publicIp.address, 'address', '203.0.113.1')
          .having((state) => state.publicIp.source, 'source', 'test'),
    ],
    verify: (_) => verify(() => service.fetch()).called(1),
  );
}
