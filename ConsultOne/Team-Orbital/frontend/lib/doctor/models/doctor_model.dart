class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String licenceId;
  final String availTime;
  final int fees;
  final String speciality;
  final String? fcmToken;

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenceId,
    required this.availTime,
    required this.fees,
    required this.speciality,
    this.fcmToken,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      licenceId: json['licenceId'] ?? '',
      availTime: json['availTime'] ?? '',
      fees: json['fees'] ?? 0,
      speciality: json['speciality'] ?? '',
      fcmToken: json['fcmToken'],
    );
  }
}
