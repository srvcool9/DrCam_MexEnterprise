import 'package:doctorcam/constants/queries.dart';
import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/models/patient_images.dart';

class Patientimagesrepository {
  final dbConfig = DatabaseConfig<PatientImages>();
  final database = DatabaseConfig().database;

  Future<int> insertImage(PatientImages image) async {
    return await dbConfig.insert(image);
  }

  // Example function to update a user
  Future<int> updateImage(PatientImages image) async {
    return await dbConfig.update(image);
  }

  Future<List<int>> insertImageList(List<PatientImages> imageList) async {
    return await dbConfig.insertMany(imageList);
  }

  Future<List<PatientImages>> getAllImages() async {
    return await dbConfig.queryAll(
      'patient_images',
      (map) => PatientImages.map(map), // Corrected constructor usage
    );
  }

  Future<PatientImages?> getPatientImagesByFeildName(
    String tableName,
    String columnName,
    dynamic columnValue,
  ) async {
    return await dbConfig.queryByColumn(
      tableName,
      columnName,
      columnValue,
      PatientImages.map,
    );
  }

  Future<List<PatientImages>> getImagesByPatientId(int param) async {
  return await dbConfig.customQuery(
    Queries.GET_PATIENT_IMAGES_BY_PATIENT_ID,
    PatientImages.map,
    param,
  );
}
}
