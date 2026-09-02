import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/public_ip_client.dart';
import '../../../../core/utils/error_message.dart';

sealed class PublicIpState {
  const PublicIpState();
}

final class PublicIpInitial extends PublicIpState {
  const PublicIpInitial();
}

final class PublicIpLoading extends PublicIpState {
  const PublicIpLoading();
}

final class PublicIpLoaded extends PublicIpState {
  const PublicIpLoaded(this.publicIp);

  final PublicIp publicIp;
}

final class PublicIpFailure extends PublicIpState {
  const PublicIpFailure(this.message);

  final String message;
}

class PublicIpCubit extends Cubit<PublicIpState> {
  PublicIpCubit(this._service) : super(const PublicIpInitial());

  final PublicIpService _service;

  Future<void> load() async {
    emit(const PublicIpLoading());
    try {
      emit(PublicIpLoaded(await _service.fetch()));
    } catch (error) {
      emit(PublicIpFailure(errorMessage(error)));
    }
  }
}
