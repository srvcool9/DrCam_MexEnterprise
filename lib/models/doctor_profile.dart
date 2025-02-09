import 'dart:ffi';

import 'package:doctorcam/models/databasemodel.dart';

class DoctorProfile implements DatabaseModel {
  int? id;
  late String agencyName;
  late int contactNumber;
  late String email;
  late String password;

 

  DoctorProfile({this.id, required this.agencyName,required this.contactNumber,required this.email,required this.password});
 // Converts the object to a Map for database storage
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agencyName': agencyName,
      'contactNumber': contactNumber,
      'email': email,
      'password': password
    };
  }

  // Converts a Map from the database to a DoctorProfile object
  @override
  DoctorProfile fromMap(Map<String, dynamic> map) {
    return DoctorProfile(
      id: map['id'],
      agencyName: map['agencyName'],
      contactNumber: map['contactNumber'],
      email: map['email'],
      password: map['password']
    );
  }


  // Returns the table name for this model
  @override
  String getTableName() {
    return 'doctor_profile';
  }
}
