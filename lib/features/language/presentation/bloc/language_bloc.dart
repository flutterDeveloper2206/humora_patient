import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/language/data/models/language_model.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageInitial()) {
    on<LoadLanguages>(_onLoadLanguages);
    on<ToggleLanguage>(_onToggleLanguage);
    on<ClearAllLanguages>(_onClearAllLanguages);
  }

  void _onLoadLanguages(LoadLanguages event, Emitter<LanguageState> emit) {
    emit(LanguageLoading());
    try {
      // Dummy JSON data as suggested
      final List<Map<String, dynamic>> dummyData = [
        {"id": 1, "languageName": "English"},
        {"id": 2, "languageName": "Hindi"},
        {"id": 3, "languageName": "Gujrati"},
        {"id": 4, "languageName": "Assamese"},
        {"id": 5, "languageName": "Punjabi"},
        {"id": 6, "languageName": "Odia"},
        {"id": 7, "languageName": "Sanskrit"},
        {"id": 8, "languageName": "Marathi"},
        {"id": 9, "languageName": "Bodo"},
      ];

      final languages = dummyData
          .map((e) => LanguageModel.fromJson(e))
          .toList();
      emit(
        LanguageLoaded(
          languages: languages,
          selectedIds: const {1, 2}, // Initial mock selection
        ),
      );
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }

  void _onToggleLanguage(ToggleLanguage event, Emitter<LanguageState> emit) {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      final updatedSelectedIds = Set<int>.from(currentState.selectedIds);

      if (updatedSelectedIds.contains(event.languageId)) {
        updatedSelectedIds.remove(event.languageId);
      } else {
        updatedSelectedIds.add(event.languageId);
      }

      emit(currentState.copyWith(selectedIds: updatedSelectedIds));
    }
  }

  void _onClearAllLanguages(
    ClearAllLanguages event,
    Emitter<LanguageState> emit,
  ) {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      emit(currentState.copyWith(selectedIds: {}));
    }
  }
}
