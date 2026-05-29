import 'package:equatable/equatable.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object?> get props => [];
}

class LoadReceipt extends ReceiptEvent {}
