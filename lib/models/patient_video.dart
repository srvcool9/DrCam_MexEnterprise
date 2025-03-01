import 'package:doctorcam/models/databasemodel.dart';


class PatientVideos implements DatabaseModel {

  final int? id;
  final int patientId;
  final int historyId;
  final String videoPath;
  final String createdOn;

  PatientVideos(
      {required this.id,
      required this.patientId,
      required this.historyId,
      required this.videoPath,
      required this.createdOn});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'historyId': historyId,
      'videoPath': videoPath,
      'createdOn': createdOn,
    };
  }

  @override
  DatabaseModel fromMap(Map<String, dynamic> map) {
    return PatientVideos(
      id: map['id'],
      patientId: map['patientId'],
      historyId: map['historyId'],
      videoPath: map['videoPath'],
      createdOn: map['createdOn'],
    );
   }

   static PatientVideos map(Map<String, dynamic> map) {
    return PatientVideos(
      id: map['id'],
      patientId: map['patientId'],
      historyId: map['historyId'],
      videoPath: map['videoPath'],
      createdOn: map['createdOn'],
    );
   }

    @override
    String getTableName() {
      return 'patient_videos';
    }
}
