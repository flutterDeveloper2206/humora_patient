import 'package:equatable/equatable.dart';

abstract class HealerEvent extends Equatable {
  const HealerEvent();

  @override
  List<Object?> get props => [];
}

class FetchHealersRequested extends HealerEvent {}

class SearchHealersRequested extends HealerEvent {
  final String query;
  const SearchHealersRequested(this.query);

  @override
  List<Object?> get props => [query];
}
