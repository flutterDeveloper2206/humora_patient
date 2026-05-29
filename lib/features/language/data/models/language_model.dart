import 'package:equatable/equatable.dart';

class LanguageModel extends Equatable {
  final int id;
  final String languageName;

  const LanguageModel({required this.id, required this.languageName});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as int,
      languageName: json['languageName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'languageName': languageName};
  }

  @override
  List<Object?> get props => [id, languageName];
}
