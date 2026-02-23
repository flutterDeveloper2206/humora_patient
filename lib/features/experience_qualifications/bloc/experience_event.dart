import 'package:equatable/equatable.dart';

abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

class UpdatePracticeMethod extends ExperienceEvent {
  final String method;
  const UpdatePracticeMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class SubmitExperience extends ExperienceEvent {}
