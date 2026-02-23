import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/certificate_model.dart';
import 'certificates_event.dart';
import 'certificates_state.dart';

class CertificatesBloc extends Bloc<CertificatesEvent, CertificatesState> {
  CertificatesBloc() : super(CertificatesInitial()) {
    on<LoadCertificates>(_onLoadCertificates);
    on<ToggleCertificateSelection>(_onToggleCertificateSelection);
    on<SearchCertificates>(_onSearchCertificates);
    on<PickCertificateFile>(_onPickCertificateFile);
    on<RemovePickedFile>(_onRemovePickedFile);
  }

  Future<void> _onPickCertificateFile(
    PickCertificateFile event,
    Emitter<CertificatesState> emit,
  ) async {
    if (state is CertificatesLoaded) {
      final currentState = state as CertificatesLoaded;
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        );

        if (result != null && result.files.single.path != null) {
          final file = result.files.single;
          final sizeKb = (file.size / 1024).toStringAsFixed(0);
          emit(
            currentState.copyWith(
              pickedFileName: file.name,
              pickedFileSize: '$sizeKb KB',
            ),
          );
        }
      } catch (e) {
        // Handle error silently or log
      }
    }
  }

  void _onRemovePickedFile(
    RemovePickedFile event,
    Emitter<CertificatesState> emit,
  ) {
    if (state is CertificatesLoaded) {
      final currentState = state as CertificatesLoaded;
      // We need a proper way to nullify in copyWith or a separate method
      emit(
        CertificatesLoaded(
          allCertificates: currentState.allCertificates,
          filteredCertificates: currentState.filteredCertificates,
          selectedCertificates: currentState.selectedCertificates,
          searchQuery: currentState.searchQuery,
          pickedFileName: null,
          pickedFileSize: null,
        ),
      );
    }
  }

  void _onLoadCertificates(
    LoadCertificates event,
    Emitter<CertificatesState> emit,
  ) {
    emit(CertificatesLoading());
    try {
      final List<Map<String, dynamic>> dummyData = [
        {
          "id": 1,
          "title": "Yoga Instructor Certification",
          "provider": "Mind Harmony",
        },
        {
          "id": 2,
          "title": "Tarot Reading Certification",
          "provider": "Spiritual Guidance",
        },
        {
          "id": 3,
          "title": "Life Coach Certification",
          "provider": "Personal Growth",
        },
        {
          "id": 4,
          "title": "Reiki Practitioner Certification",
          "provider": "Energy Alignment",
        },
        {
          "id": 5,
          "title": "Chakra Healing Certification",
          "provider": "Chakra Balance",
        },
        {
          "id": 6,
          "title": "Pranic Healing Certification",
          "provider": "Aura Cleansing",
        },
        {
          "id": 7,
          "title": "Crystal Healing Certification",
          "provider": "Crystal Therapy",
        },
        {
          "id": 8,
          "title": "Meditation Teacher Certification",
          "provider": "Mental Clarity",
        },
      ];

      final certificates = dummyData
          .map((e) => CertificateModel.fromJson(e))
          .toList();

      // Initially Yoga, Tarot, and Life Coach are selected as per UI screenshot
      final initialSelected = [
        certificates[0],
        certificates[1],
        certificates[2],
      ];
      final initialPopular = certificates.sublist(3);

      emit(
        CertificatesLoaded(
          allCertificates: certificates,
          filteredCertificates: initialPopular,
          selectedCertificates: initialSelected,
        ),
      );
    } catch (e) {
      emit(CertificatesError(e.toString()));
    }
  }

  void _onToggleCertificateSelection(
    ToggleCertificateSelection event,
    Emitter<CertificatesState> emit,
  ) {
    if (state is CertificatesLoaded) {
      final currentState = state as CertificatesLoaded;
      final selected = List<CertificateModel>.from(
        currentState.selectedCertificates,
      );

      if (selected.contains(event.certificate)) {
        selected.remove(event.certificate);
      } else {
        selected.add(event.certificate);
      }

      emit(currentState.copyWith(selectedCertificates: selected));
    }
  }

  void _onSearchCertificates(
    SearchCertificates event,
    Emitter<CertificatesState> emit,
  ) {
    if (state is CertificatesLoaded) {
      final currentState = state as CertificatesLoaded;
      final query = event.query.toLowerCase();

      final filtered = currentState.allCertificates.where((cert) {
        final matchesQuery =
            cert.title.toLowerCase().contains(query) ||
            cert.provider.toLowerCase().contains(query);
        final isNotSelected = !currentState.selectedCertificates.contains(cert);
        return matchesQuery && isNotSelected;
      }).toList();

      emit(
        currentState.copyWith(
          filteredCertificates: filtered,
          searchQuery: event.query,
        ),
      );
    }
  }
}
