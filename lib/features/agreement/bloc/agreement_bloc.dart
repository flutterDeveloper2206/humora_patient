import 'package:flutter_bloc/flutter_bloc.dart';
import 'agreement_event.dart';
import 'agreement_state.dart';

class AgreementBloc extends Bloc<AgreementEvent, AgreementState> {
  AgreementBloc() : super(const AgreementState()) {
    on<ToggleTerms>((event, emit) {
      emit(state.copyWith(termsAccepted: !state.termsAccepted));
    });
    on<ToggleEthics>((event, emit) {
      emit(state.copyWith(ethicsAccepted: !state.ethicsAccepted));
    });
  }
}
