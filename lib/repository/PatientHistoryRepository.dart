import 'package:doctorcam/constants/queries.dart';
import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/dto/PatientHistoryDTO.dart';
import 'package:doctorcam/models/patient_history.dart';

class Patienthistoryrepository {
  final dbConfig = DatabaseConfig<PatientHistory>();
  final database = DatabaseConfig().database;

  Future<int> insertPatientHistory(PatientHistory patient) async {
    return await dbConfig.insert(patient);
  }

  Future<int> updatePatient(PatientHistory patient) async {
    return await dbConfig.update(patient);
  }

Future<List<String>> getPreviousApointment(int param) async {
  return await dbConfig.customQuery(
    Queries.GET_PATIENT_APOINTMENT_DATES,
    (map) => map['appointment_date'].toString(),
    param,
  );
}
   
Future<List<PatientHistoryDto>> getGridData() async {
    return await dbConfig.getGridData();
  }


Future<int> getDashboardData(String query) async {
  return await dbConfig.retriveIntOutput(query, []);
}
  
}
