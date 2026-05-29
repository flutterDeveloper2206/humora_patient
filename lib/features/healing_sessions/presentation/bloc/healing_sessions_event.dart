part of 'healing_sessions_bloc.dart';

abstract class HealingSessionsEvent {
  const HealingSessionsEvent();
}

class ToggleTab extends HealingSessionsEvent {
  final HealingSessionTab tab;
  const ToggleTab(this.tab);
}

class UpdateMinPrice extends HealingSessionsEvent {
  final double price;
  const UpdateMinPrice(this.price);
}

class UpdateFixedTime extends HealingSessionsEvent {
  final int time;
  const UpdateFixedTime(this.time);
}

class UpdateMaxCapacity extends HealingSessionsEvent {
  final int capacity;
  const UpdateMaxCapacity(this.capacity);
}

class UpdateSessionPrice extends HealingSessionsEvent {
  final double price;
  const UpdateSessionPrice(this.price);
}

class UpdateSessionTime extends HealingSessionsEvent {
  final int time;
  const UpdateSessionTime(this.time);
}

class SubmitHealingSessions extends HealingSessionsEvent {
  const SubmitHealingSessions();
}
