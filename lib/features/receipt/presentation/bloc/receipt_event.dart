import 'package:equatable/equatable.dart';
import '../models/receipt_args.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object?> get props => [];
}

class LoadReceipt extends ReceiptEvent {
  final ReceiptArgs? args;

  const LoadReceipt({this.args});

  @override
  List<Object?> get props => [args];
}
