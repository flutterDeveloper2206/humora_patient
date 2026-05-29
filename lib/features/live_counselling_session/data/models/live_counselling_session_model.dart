import 'package:equatable/equatable.dart';

class LiveCounsellingSessionModel extends Equatable {
  final int id;
  final String image;
  final String value;
  final int price;

  const LiveCounsellingSessionModel({
    required this.id,
    required this.image,
    required this.value,
    required this.price,
  });

  factory LiveCounsellingSessionModel.fromJson(Map<String, dynamic> json) {
    return LiveCounsellingSessionModel(
      id: json['id'] as int,
      image: json['image'] as String,
      value: json['value'] as String,
      price: json['price'] as int,
    );
  }

  @override
  List<Object?> get props => [id, image, value, price];
}
