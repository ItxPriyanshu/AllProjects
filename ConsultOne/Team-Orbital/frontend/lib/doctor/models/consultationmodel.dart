import 'package:frontend/doctor/models/doctor_model.dart';

class Consultationmodel {
  final String id;
  final String fullName;
  final DateTime createdAt;
  final String status;
  final String type;
  final String? patientFileUrl;
  final String? doctorFileUrl;
  final String? age;
  final String? gender;
  final String? contactNo;
  final String? problem;
  final String? lifeStyle;
  final Map<String, dynamic>? patientFormData;
  final String doctorId;
  final DoctorModel? doctor;

  Consultationmodel({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.status,
    required this.type,
    this.patientFileUrl,
    this.doctorFileUrl,
    this.age,
    this.gender,
    this.contactNo,
    this.problem,
    this.lifeStyle,
    this.patientFormData,
    required this.doctorId,
    this.doctor,
  });

  factory Consultationmodel.fromJson(Map<String, dynamic> json) {
    try {
      DoctorModel? parsedDoctor;
      if (json['doctor_id'] != null) {
        final doctorData = json['doctor_id'];
        if (doctorData is Map<String, dynamic>) {
          parsedDoctor = DoctorModel.fromJson(doctorData);
        } else if (doctorData is String) {
          print("WARNING: doctor_id is a string, not a map: $doctorData");
        }
      }

      return Consultationmodel(
        id: json['_id'] ?? '',
        fullName: json['full_name'] ?? '',
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
        status: json['status'] ?? 'pending',
        type: json['type'] ?? 'normal',
        patientFileUrl: json['patientFileUrl'],
        doctorFileUrl: json['doctorFileUrl'],
        age: json['age']?.toString(),
        gender: json['gender']?.toString(),
        contactNo: json['contactNo']?.toString(),
        problem: json['Problem']?.toString() ?? json['problem']?.toString(),
        lifeStyle: json['life_style']?.toString() ?? json['lifestyle']?.toString(),
        patientFormData: json['patientForm'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['patientForm'])
            : // fallback: collect known form-related keys into a map
            {
          if (json['full_name'] != null) 'full_name': json['full_name'],
          if (json['age'] != null) 'age': json['age'],
          if (json['gender'] != null) 'gender': json['gender'],
          if (json['contactNo'] != null) 'contactNo': json['contactNo'],
          if (json['Problem'] != null) 'Problem': json['Problem'],
          if (json['problem'] != null) 'problem': json['problem'],
          if (json['life_style'] != null) 'life_style': json['life_style'],
          if (json['lifestyle'] != null) 'lifestyle': json['lifestyle'],
          if (json['patientFileUrl'] != null) 'patientFileUrl': json['patientFileUrl'],
        },
        doctorId: json['doctor_id'] is String ? json['doctor_id'] : (json['doctor_id']?['_id'] ?? ''),
        doctor: parsedDoctor,
      );
    } catch (e) {
      print("ERROR in Consultationmodel.fromJson: $e");
      rethrow;
    }
  }
}


class DoctorInfo {
  final String name;
  final String speciality;

  DoctorInfo({required this.name, required this.speciality});

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(name: json['name'], speciality: json['speciality']);
  }
}
