import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/doctor/docHistory/consultation_model.dart';

final doctorHistoryProvider =
    FutureProvider<List<ConsultationModel>>((ref) async {
  // call repository / API here
  return [];
});
