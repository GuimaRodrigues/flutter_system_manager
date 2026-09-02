import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/platform/system_service.dart';
import '../../../../core/utils/error_message.dart';
import '../../domain/system_process.dart';

sealed class ProcessesState {
  const ProcessesState();
}

final class ProcessesInitial extends ProcessesState {
  const ProcessesInitial();
}

final class ProcessesLoading extends ProcessesState {
  const ProcessesLoading();
}

final class ProcessesLoaded extends ProcessesState {
  const ProcessesLoaded(this.processes);

  final List<SystemProcess> processes;
}

final class ProcessesFailure extends ProcessesState {
  const ProcessesFailure(this.message);

  final String message;
}

class ProcessesCubit extends Cubit<ProcessesState> {
  ProcessesCubit(this._service) : super(const ProcessesInitial());

  final SystemService _service;

  Future<void> load() async {
    emit(const ProcessesLoading());
    try {
      emit(ProcessesLoaded(await _service.getProcesses()));
    } catch (error) {
      emit(ProcessesFailure(errorMessage(error)));
    }
  }
}
