import 'package:doctorcam/models/databasemodel.dart';

class PatientHistory implements DatabaseModel {
  final int? id;
  final int patientId;
  final String appointmentId;
  final String appointmentDate;
  final String createdOn;

  PatientHistory({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    required this.appointmentDate,
    required this.createdOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'appointmentId':appointmentId,
      'appointmentDate': appointmentDate,
      'createdOn': createdOn,
    };
  }

  @override
  DatabaseModel fromMap(Map<String, dynamic> map) {
    return PatientHistory(
      id: map['id'],
      patientId: map['patientId'],
      appointmentId: map['appointmentId'],
      appointmentDate: map['appointmentDate'],
      createdOn: map['createdOn'],
    );
   }

    static PatientHistory map(Map<String, dynamic> map) {
    return PatientHistory(
      id: map['id'],
      patientId: map['patientId'],
       appointmentId: map['appointmentId'],
      appointmentDate: map['appointmentDate'],
      createdOn: map['createdOn'],
    );
   }
    @override
    String getTableName() {
      return 'patient_history';
    }
  }

