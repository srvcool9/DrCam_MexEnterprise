
import 'package:doctorcam/db_config/database_config.dart';
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
}