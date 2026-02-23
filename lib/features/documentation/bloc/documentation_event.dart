import 'package:equatable/equatable.dart';

abstract class DocumentationEvent extends Equatable {
  const DocumentationEvent();
  @override
  List<Object?> get props => [];
}

class ToggleSelfDeclaration extends DocumentationEvent {}

class PickFileEvent extends DocumentationEvent {
  final String section;
  const PickFileEvent(this.section);
  @override
  List<Object?> get props => [section];
}

class DeleteFileEvent extends DocumentationEvent {
  final String section;
  const DeleteFileEvent(this.section);
  @override
  List<Object?> get props => [section];
}
