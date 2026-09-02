import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/platform/system_service.dart';
import '../../../../core/utils/error_message.dart';
import '../../domain/system_info.dart';

sealed class SystemState {
  const SystemState();
}

final class SystemInitial extends SystemState {
  const SystemInitial();
}

final class SystemLoading extends SystemState {
  const SystemLoading();
}

final class SystemLoaded extends SystemState {
  const SystemLoaded(this.info);

  final SystemInfo info;
}

final class SystemFailure extends SystemState {
  const SystemFailure(this.message);

  final String message;
}

class SystemCubit extends Cubit<SystemState> {
  SystemCubit(this._service) : super(const SystemInitial());

  final SystemService _service;

  Future<void> load() async {
    emit(const SystemLoading());
    try {
      emit(SystemLoaded(await _service.getSystemInfo()));
    } catch (error) {
      emit(SystemFailure(errorMessage(error)));
    }
  }
}
