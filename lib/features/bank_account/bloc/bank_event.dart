import 'package:equatable/equatable.dart';
import '../models/bank_model.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();
  @override
  List<Object?> get props => [];
}

class LoadBanks extends BankEvent {}

class SearchBanks extends BankEvent {
  final String query;
  const SearchBanks(this.query);
  @override
  List<Object?> get props => [query];
}

class SelectBank extends BankEvent {
  final BankModel bank;
  const SelectBank(this.bank);
  @override
  List<Object?> get props => [bank];
}
