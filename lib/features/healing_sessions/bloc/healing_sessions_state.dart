part of 'healing_sessions_bloc.dart';

enum HealingSessionTab { personal, group }

enum HealingSessionStatus { initial, loading, success, failure }

class HealingSessionsState {
  final HealingSessionTab tab;
  final double minPrice;
  final int fixedTime;
  final int maxCapacity;
  final double sessionPrice;
  final int sessionTime;
  final HealingSessionStatus status;
  final String? errorMessage;

  const HealingSessionsState({
    this.tab = HealingSessionTab.personal,
    this.minPrice = 120.0,
    this.fixedTime = 45,
    this.maxCapacity = 20,
    this.sessionPrice = 5.00,
    this.sessionTime = 15,
    this.status = HealingSessionStatus.initial,
    this.errorMessage,
  });

  HealingSessionsState copyWith({
    HealingSessionTab? tab,
    double? minPrice,
    int? fixedTime,
    int? maxCapacity,
    double? sessionPrice,
    int? sessionTime,
    HealingSessionStatus? status,
    String? errorMessage,
  }) {
    return HealingSessionsState(
      tab: tab ?? this.tab,
      minPrice: minPrice ?? this.minPrice,
      fixedTime: fixedTime ?? this.fixedTime,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      sessionPrice: sessionPrice ?? this.sessionPrice,
      sessionTime: sessionTime ?? this.sessionTime,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
