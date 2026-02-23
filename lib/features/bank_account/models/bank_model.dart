import 'package:equatable/equatable.dart';

class BankModel extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final bool isPopular;

  const BankModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isPopular = false,
  });

  @override
  List<Object?> get props => [id, name, logoUrl, isPopular];
}
