// ignore_for_file: public_member_api_docs, sort_constructors_first
class DoctorSignupModel {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String licenceId;  // Changed from licenseNumber
  final String speciality;
  final double fees;  // Changed to double (number)
  final String availTime;  // Combined availability time
  final String experience;

  DoctorSignupModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.licenceId,
    required this.speciality,
    required this.fees,
    required this.availTime,
    required this.experience,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "phone": phone,
      "licenceId": licenceId,
      "speciality": speciality,
      "fees": fees,  // Now a number
      "availTime": availTime,  // Combined time
      "experience":experience,
    };
  }
}
