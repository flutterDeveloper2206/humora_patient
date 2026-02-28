import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  PaymentMethodBloc() : super(const PaymentMethodState()) {
    on<SelectPaymentMethod>((event, emit) {
      emit(state.copyWith(selectedType: event.type));
    });

    on<ApplyDiscountCode>((event, emit) {
      emit(state.copyWith(discountCode: event.code));
    });
  }
}
