import 'package:equatable/equatable.dart';

enum PaymentType { creditCard, googlePay, applePay }

class PaymentMethodState extends Equatable {
  final PaymentType selectedType;
  final String discountCode;
  final double totalAmount;
  final double originalAmount;
  final double walletBalance;

  const PaymentMethodState({
    this.selectedType = PaymentType.googlePay,
    this.discountCode = 'AZSWIDHSB128BS',
    this.totalAmount = 85.00,
    this.originalAmount = 100.00,
    this.walletBalance = 3580.95,
  });

  PaymentMethodState copyWith({
    PaymentType? selectedType,
    String? discountCode,
    double? totalAmount,
    double? originalAmount,
    double? walletBalance,
  }) {
    return PaymentMethodState(
      selectedType: selectedType ?? this.selectedType,
      discountCode: discountCode ?? this.discountCode,
      totalAmount: totalAmount ?? this.totalAmount,
      originalAmount: originalAmount ?? this.originalAmount,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [
    selectedType,
    discountCode,
    totalAmount,
    originalAmount,
    walletBalance,
  ];
}
