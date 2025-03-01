import 'package:doctorcam/constants/queries.dart';
import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/models/patient_video.dart';

class PatientVideoRepository {
  final dbConfig = DatabaseConfig<PatientVideos>();
  final database = DatabaseConfig().database;

  Future<int> insertVideoDetail(PatientVideos videoData) async {
    return await dbConfig.insert(videoData);
  }

  // Example function to update a user
  Future<int> updateVideoDetail(PatientVideos videoData) async {
    return await dbConfig.update(videoData);
  }

  Future<List<int>> insertVideoDataList(List<PatientVideos> videoDataList) async {
    return await dbConfig.insertMany(videoDataList);
  }

  Future<List<PatientVideos>> getAllVideos() async {
    return await dbConfig.queryAll(
      'patient_videos',
      (map) => PatientVideos.map(map), // Corrected constructor usage
    );
  }

  Future<PatientVideos?> getPatientVideosByFeildName(
    String tableName,
    String columnName,
    dynamic columnValue,
  ) async {
    return await dbConfig.queryByColumn(
      tableName,
      columnName,
      columnValue,
      PatientVideos.map,
    );
  }

  Future<List<PatientVideos>> getVideosByPatientId(int param) async {
    return await dbConfig.customQuery(
      Queries.GET_PATIENT_VIDEOS_BY_PATIENT_ID,
      PatientVideos.map,
      param,
    );
  }
}
