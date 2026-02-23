import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'documentation_event.dart';
import 'documentation_state.dart';

class DocumentationBloc extends Bloc<DocumentationEvent, DocumentationState> {
  DocumentationBloc() : super(const DocumentationState()) {
    on<ToggleSelfDeclaration>((event, emit) {
      emit(state.copyWith(selfDeclaration: !state.selfDeclaration));
    });

    on<PickFileEvent>((event, emit) async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        );

        if (result != null && result.files.single.name.isNotEmpty) {
          final fileName = result.files.single.name;
          if (event.section == 'govId') {
            emit(state.copyWith(govIdFileName: fileName));
          } else {
            emit(state.copyWith(addressProofFileName: fileName));
          }
        }
      } catch (e) {
        // Handle error if needed
      }
    });

    on<DeleteFileEvent>((event, emit) {
      if (event.section == 'govId') {
        emit(state.copyWith(clearGovId: true));
      } else {
        emit(state.copyWith(clearAddress: true));
      }
    });
  }
}
