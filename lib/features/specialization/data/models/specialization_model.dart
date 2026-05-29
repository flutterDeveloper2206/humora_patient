import 'package:equatable/equatable.dart';

class SpecializationModel extends Equatable {
  final int id;
  final String value;

  const SpecializationModel({required this.id, required this.value});

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    return SpecializationModel(
      id: json['id'] as int,
      value: json['value'] as String,
    );
  }

  @override
  List<Object?> get props => [id, value];
}
