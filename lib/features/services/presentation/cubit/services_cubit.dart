import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/platform/system_service.dart';
import '../../../../core/utils/error_message.dart';
import '../../domain/windows_service.dart';

sealed class ServicesState {
  const ServicesState();
}

final class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

final class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

final class ServicesLoaded extends ServicesState {
  const ServicesLoaded(this.services);

  final List<WindowsService> services;
}

final class ServicesFailure extends ServicesState {
  const ServicesFailure(this.message);

  final String message;
}

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit(this._service) : super(const ServicesInitial());

  final SystemService _service;

  Future<void> load() async {
    emit(const ServicesLoading());
    try {
      emit(ServicesLoaded(await _service.getServices()));
    } catch (error) {
      emit(ServicesFailure(errorMessage(error)));
    }
  }
}
