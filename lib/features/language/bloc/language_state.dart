import 'package:equatable/equatable.dart';
import '../models/language_model.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final List<LanguageModel> languages;
  final Set<int> selectedIds;

  const LanguageLoaded({required this.languages, required this.selectedIds});

  LanguageLoaded copyWith({
    List<LanguageModel>? languages,
    Set<int>? selectedIds,
  }) {
    return LanguageLoaded(
      languages: languages ?? this.languages,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [languages, selectedIds];
}

class LanguageError extends LanguageState {
  final String message;

  const LanguageError(this.message);

  @override
  List<Object?> get props => [message];
}
