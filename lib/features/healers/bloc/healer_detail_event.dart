import 'package:equatable/equatable.dart';
import '../data/healer_model.dart';

abstract class HealerDetailEvent extends Equatable {
  const HealerDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadHealerDetail extends HealerDetailEvent {
  final String healerId;
  const LoadHealerDetail(this.healerId);

  @override
  List<Object?> get props => [healerId];
}

class ChangeTab extends HealerDetailEvent {
  final int index;
  const ChangeTab(this.index);

  @override
  List<Object?> get props => [index];
}

class SelectDate extends HealerDetailEvent {
  final DateTime date;
  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectTimeCategory extends HealerDetailEvent {
  final String category;
  const SelectTimeCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SelectTime extends HealerDetailEvent {
  final String time;
  const SelectTime(this.time);

  @override
  List<Object?> get props => [time];
}

class NavigateWeek extends HealerDetailEvent {
  final int weeks;
  const NavigateWeek(this.weeks);

  @override
  List<Object?> get props => [weeks];
}

class ChangeSessionType extends HealerDetailEvent {
  final SessionType sessionType;
  const ChangeSessionType(this.sessionType);

  @override
  List<Object?> get props => [sessionType];
}
