import 'package:flutter_bloc/flutter_bloc.dart';
import 'security_number_event.dart';
import 'security_number_state.dart';

class SecurityNumberBloc
    extends Bloc<SecurityNumberEvent, SecurityNumberState> {
  SecurityNumberBloc() : super(const SecurityNumberState()) {
    on<UpdateSSN>((event, emit) {
      if (event.ssn.length <= 9) {
        emit(state.copyWith(ssn: event.ssn));
      }
    });

    on<SubmitSSN>((event, emit) async {
      if (!state.isValid) return;

      emit(state.copyWith(status: SecurityNumberStatus.loading));
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: SecurityNumberStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: SecurityNumberStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
