import 'package:equatable/equatable.dart';

class ExpertiseModel extends Equatable {
  final int id;
  final String image;
  final String value;

  const ExpertiseModel({
    required this.id,
    required this.image,
    required this.value,
  });

  factory ExpertiseModel.fromJson(Map<String, dynamic> json) {
    return ExpertiseModel(
      id: json['id'] as int,
      image: json['image'] as String,
      value: json['value'] as String,
    );
  }

  @override
  List<Object?> get props => [id, image, value];
}
