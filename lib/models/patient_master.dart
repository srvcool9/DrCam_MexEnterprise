import 'package:doctorcam/models/databasemodel.dart';

class PatientMaster implements DatabaseModel {
  final int patientId;
  final String patientName;
  final String gender;
  final String dateOfBirth;
  final String phone;
  final String address;

  PatientMaster({
    required this.patientId,
    required this.patientName,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'address': address,
    };
  }

  @override
  DatabaseModel fromMap(Map<String, dynamic> map) {
    return PatientMaster(
      patientId: map['patientId'],
      patientName: map['patientName'],
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  static PatientMaster map(Map<String, dynamic> map) {
    return PatientMaster(
      patientId: map['patientId'],
      patientName: map['patientName'],
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  @override
  String getTableName() {
    return 'patients';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'address': address,
    };
  }
}
