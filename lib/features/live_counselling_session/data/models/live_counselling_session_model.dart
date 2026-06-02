import 'package:equatable/equatable.dart';

class LiveCounsellingSessionModel extends Equatable {
  final int id;
  final String image;
  final String value;
  final int price;
  /// API consultationType: 0=Chat, 1=Audio, 2=Video
  final int consultationType;

  const LiveCounsellingSessionModel({
    required this.id,
    required this.image,
    required this.value,
    required this.price,
    required this.consultationType,
  });

  factory LiveCounsellingSessionModel.fromJson(Map<String, dynamic> json) {
    return LiveCounsellingSessionModel(
      id: json['id'] as int,
      image: json['image'] as String,
      value: json['value'] as String,
      price: json['price'] as int,
      consultationType: json['consultationType'] as int,
    );
  }

  @override
  List<Object?> get props => [id, image, value, price, consultationType];
}
