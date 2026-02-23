import 'package:equatable/equatable.dart';
import '../models/bank_model.dart';

enum BankStatus { initial, loading, loaded, error }

class BankState extends Equatable {
  final BankStatus status;
  final List<BankModel> allBanks;
  final List<BankModel> filteredBanks;
  final List<BankModel> popularBanks;
  final List<BankModel> filteredPopularBanks;
  final BankModel? selectedBank;
  final String searchQuery;

  const BankState({
    this.status = BankStatus.initial,
    this.allBanks = const [],
    this.filteredBanks = const [],
    this.popularBanks = const [],
    this.filteredPopularBanks = const [],
    this.selectedBank,
    this.searchQuery = '',
  });

  BankState copyWith({
    BankStatus? status,
    List<BankModel>? allBanks,
    List<BankModel>? filteredBanks,
    List<BankModel>? popularBanks,
    List<BankModel>? filteredPopularBanks,
    BankModel? selectedBank,
    String? searchQuery,
  }) {
    return BankState(
      status: status ?? this.status,
      allBanks: allBanks ?? this.allBanks,
      filteredBanks: filteredBanks ?? this.filteredBanks,
      popularBanks: popularBanks ?? this.popularBanks,
      filteredPopularBanks: filteredPopularBanks ?? this.filteredPopularBanks,
      selectedBank: selectedBank ?? this.selectedBank,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allBanks,
    filteredBanks,
    popularBanks,
    filteredPopularBanks,
    selectedBank,
    searchQuery,
  ];
}
