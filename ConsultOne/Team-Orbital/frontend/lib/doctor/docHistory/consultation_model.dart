enum ConsultationType { normal, emergency }
enum ConsultationStatus { resolved, unresolved, cancelled }

class ConsultationModel {
  final String id;
  final String patientName;
  final String diagnosis;
  final DateTime dateTime;
  final ConsultationType type;
  final ConsultationStatus status;

  ConsultationModel({
    required this.id,
    required this.patientName,
    required this.diagnosis,
    required this.dateTime,
    required this.type,
    required this.status,
  });
}
