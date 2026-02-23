import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/bank_model.dart';
import 'bank_event.dart';
import 'bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  BankBloc() : super(const BankState()) {
    on<LoadBanks>(_onLoadBanks);
    on<SearchBanks>(_onSearchBanks);
    on<SelectBank>(_onSelectBank);
  }

  void _onLoadBanks(LoadBanks event, Emitter<BankState> emit) {
    emit(state.copyWith(status: BankStatus.loading));

    // Mock data for banks
    final allBanks = [
      const BankModel(id: '1', name: 'State Bank of India', isPopular: true),
      const BankModel(id: '2', name: 'HDFC', isPopular: true),
      const BankModel(id: '3', name: 'ICICI Bank', isPopular: true),
      const BankModel(id: '4', name: 'Union Bank of India', isPopular: true),
      const BankModel(id: '5', name: 'Kotak Mahindra Bank', isPopular: true),
      const BankModel(id: '6', name: 'Bank of Baroda', isPopular: true),
      const BankModel(id: '7', name: 'Axis Bank', isPopular: true),
      const BankModel(id: '8', name: 'Canara Bank', isPopular: true),
      const BankModel(id: '9', name: 'Paytm Payments Bank', isPopular: true),
      const BankModel(id: '10', name: 'Punjab National Bank'),
      const BankModel(id: '11', name: 'Bank of India'),
      const BankModel(id: '12', name: 'IDBI Bank'),
      const BankModel(id: '13', name: 'IndusInd Bank'),
      const BankModel(id: '14', name: 'Yes Bank'),
    ];

    final popularBanks = allBanks.where((b) => b.isPopular).toList();

    emit(
      state.copyWith(
        status: BankStatus.loaded,
        allBanks: allBanks,
        filteredBanks: allBanks,
        popularBanks: popularBanks,
        filteredPopularBanks: popularBanks,
      ),
    );
  }

  void _onSearchBanks(SearchBanks event, Emitter<BankState> emit) {
    final query = event.query.toLowerCase();

    final filteredBanks = state.allBanks
        .where((bank) => bank.name.toLowerCase().contains(query))
        .toList();

    final filteredPopular = state.popularBanks
        .where((bank) => bank.name.toLowerCase().contains(query))
        .toList();

    emit(
      state.copyWith(
        filteredBanks: filteredBanks,
        filteredPopularBanks: filteredPopular,
        searchQuery: event.query,
      ),
    );
  }

  void _onSelectBank(SelectBank event, Emitter<BankState> emit) {
    emit(state.copyWith(selectedBank: event.bank));
  }
}
