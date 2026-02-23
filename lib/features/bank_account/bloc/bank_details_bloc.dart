import 'package:flutter_bloc/flutter_bloc.dart';
import 'bank_details_event.dart';
import 'bank_details_state.dart';

class BankDetailsBloc extends Bloc<BankDetailsEvent, BankDetailsState> {
  BankDetailsBloc() : super(const BankDetailsState()) {
    on<UpdateAccountHolderName>((event, emit) {
      emit(state.copyWith(accountHolderName: event.name));
    });
    on<UpdateAccountNumber>((event, emit) {
      emit(state.copyWith(accountNumber: event.number));
    });
    on<UpdateIFSCCode>((event, emit) {
      emit(state.copyWith(ifscCode: event.code));
    });
    on<UpdateUPI>((event, emit) {
      emit(state.copyWith(upi: event.upi));
    });
    on<UpdatePANNumber>((event, emit) {
      emit(state.copyWith(panNumber: event.pan));
    });
    on<UpdateGSTNumber>((event, emit) {
      emit(state.copyWith(gstNumber: event.gst));
    });
    on<SubmitBankDetails>((event, emit) async {
      if (!state.isValid) return;

      emit(state.copyWith(status: BankDetailsStatus.loading));
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: BankDetailsStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: BankDetailsStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
