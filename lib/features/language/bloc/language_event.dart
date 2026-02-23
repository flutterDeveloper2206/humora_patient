import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class LoadLanguages extends LanguageEvent {}

class ToggleLanguage extends LanguageEvent {
  final int languageId;

  const ToggleLanguage(this.languageId);

  @override
  List<Object?> get props => [languageId];
}

class ClearAllLanguages extends LanguageEvent {}
