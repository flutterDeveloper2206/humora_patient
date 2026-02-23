import 'package:equatable/equatable.dart';

class CertificateModel extends Equatable {
  final int id;
  final String title;
  final String provider;

  const CertificateModel({
    required this.id,
    required this.title,
    required this.provider,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] as int,
      title: json['title'] as String,
      provider: json['provider'] as String,
    );
  }

  @override
  List<Object?> get props => [id, title, provider];
}
