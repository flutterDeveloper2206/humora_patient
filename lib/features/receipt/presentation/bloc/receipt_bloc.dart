import 'package:flutter_bloc/flutter_bloc.dart';
import 'receipt_event.dart';
import 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  ReceiptBloc() : super(const ReceiptState()) {
    on<LoadReceipt>((event, emit) {
      // For now, it just emits the default state with mock data
    });
  }
}
