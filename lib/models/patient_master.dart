import 'package:doctorcam/models/databasemodel.dart';

class PatientMaster implements DatabaseModel {
  final int? patientId;
  final String appointmentId;
  final String patientName;
  final String gender;
  final String dateOfBirth;
  final String phone;
  final String address;

  PatientMaster({
    required this.patientId,
    required this.appointmentId,
    required this.patientName,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'appointmentId':appointmentId,
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
      appointmentId: map['appointmentId'],
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
      appointmentId: map['appointmentId'],
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
      'appointmentId': appointmentId,
      'patientName': patientName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'address': address,
    };
  }
}
