import 'package:doctorcam/models/databasemodel.dart';

class PatientImages implements DatabaseModel {
  final int? id;
  final int patientId;
  final int historyId;
  final String imageBase64;
  final String createdOn;

  PatientImages(
      {required this.id,
      required this.patientId,
      required this.historyId,
      required this.imageBase64,
      required this.createdOn});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'historyId': historyId,
      'imageBase64': imageBase64,
      'createdOn': createdOn,
    };
  }

  @override
  DatabaseModel fromMap(Map<String, dynamic> map) {
    return PatientImages(
      id: map['id'],
      patientId: map['patientId'],
      historyId: map['historyId'],
      imageBase64: map['imageBase64'],
      createdOn: map['createdOn'],
    );
   }

   static PatientImages map(Map<String, dynamic> map) {
    return PatientImages(
      id: map['id'],
      patientId: map['patientId'],
      historyId: map['historyId'],
      imageBase64: map['imageBase64'],
      createdOn: map['createdOn'],
    );
   }

    @override
    String getTableName() {
      return 'patient_images';
    }
}
