class UserProfileModel {
  final String id;
  final String profilePic;
  final String coverImage;
  final String firstName;
  final String lastName;
  final String fullName;
  final int? gender;
  final String? dob;
  final String mobile;
  final String address1;
  final String address2;
  final String email;

  const UserProfileModel({
    required this.id,
    required this.profilePic,
    required this.coverImage,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.gender,
    this.dob,
    required this.mobile,
    required this.address1,
    required this.address2,
    required this.email,
  });

  String get displayName {
    final full = fullName.trim();
    if (full.isNotEmpty) return full;
    final joined = '$firstName $lastName'.trim();
    return joined.isNotEmpty ? joined : 'Patient';
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return UserProfileModel(
      id: data['id']?.toString() ?? '',
      profilePic: data['profilePic']?.toString() ?? '',
      coverImage: data['coverImage']?.toString() ?? '',
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      fullName: data['fullName']?.toString() ?? '',
      gender: data['gender'] is num ? (data['gender'] as num).toInt() : int.tryParse(data['gender']?.toString() ?? ''),
      dob: data['dob']?.toString(),
      mobile: data['mobile']?.toString() ?? '',
      address1: data['address1']?.toString() ?? '',
      address2: data['address2']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profilePic': profilePic,
      'coverImage': coverImage,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'gender': gender,
      'dob': dob,
      'mobile': mobile,
      'address1': address1,
      'address2': address2,
      'email': email,
    };
  }
}

class UpdateUserProfileRequest {
  final String firstName;
  final String lastName;
  final String mobile;
  final String address1;
  final String address2;
  final int gender;
  final String dob;

  const UpdateUserProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.address1,
    required this.address2,
    required this.gender,
    required this.dob,
  });

  Map<String, String> toFormFields() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Mobile': mobile,
      'Address1': address1,
      'Address2': address2,
      'Gender': gender.toString(),
      'DOB': dob,
    };
  }
}
