import 'package:equatable/equatable.dart';

abstract class MySessionsEvent extends Equatable {
  const MySessionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMySessions extends MySessionsEvent {
  const LoadMySessions();
}

class RefreshMySessions extends MySessionsEvent {
  const RefreshMySessions();
}
