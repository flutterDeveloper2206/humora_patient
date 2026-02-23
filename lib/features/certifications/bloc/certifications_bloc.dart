import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'certifications_event.dart';
import 'certifications_state.dart';

class CertificationsBloc
    extends Bloc<CertificationsEvent, CertificationsState> {
  CertificationsBloc() : super(const CertificationsState()) {
    on<PickCertFile>((event, emit) async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        );

        if (result != null && result.files.single.path != null) {
          final file = result.files.single;
          final sizeKb = (file.size / 1024).toStringAsFixed(0);
          emit(state.copyWith(fileName: file.name, fileSize: '$sizeKb KB'));
        }
      } catch (e) {
        emit(
          state.copyWith(
            status: CertificationsStatus.error,
            errorMessage: "Failed to pick file: $e",
          ),
        );
      }
    });

    on<RemoveCertFile>((event, emit) {
      emit(state.clearFile());
    });

    on<SubmitCertifications>((event, emit) async {
      if (!state.isFileUploaded) return;
      emit(state.copyWith(status: CertificationsStatus.loading));
      try {
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: CertificationsStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: CertificationsStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
