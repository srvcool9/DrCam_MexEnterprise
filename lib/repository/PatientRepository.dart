import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/models/patient_master.dart';

class Patientrepository {
  final dbConfig = DatabaseConfig<PatientMaster>();
  final database = DatabaseConfig().database;

  Future<int> insertPatient(PatientMaster patient) async {
    return await dbConfig.insert(patient);
  }

  // Example function to update a patient
  Future<int> updatePatient(PatientMaster patient) async {
    return await dbConfig.updatePatient(patient);
  }

  Future<PatientMaster?> getPatientDetailByFeildName(
    String tableName,
    String columnName,
    dynamic columnValue,
  ) async {
    return await dbConfig.queryByColumn(
      tableName,
      columnName,
      columnValue,
      PatientMaster.map,
    );
  }
}
