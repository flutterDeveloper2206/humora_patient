import 'package:equatable/equatable.dart';
import 'payment_state.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class SelectPaymentMethod extends PaymentMethodEvent {
  final PaymentType type;
  const SelectPaymentMethod(this.type);

  @override
  List<Object?> get props => [type];
}

class ApplyDiscountCode extends PaymentMethodEvent {
  final String code;
  const ApplyDiscountCode(this.code);

  @override
  List<Object?> get props => [code];
}
