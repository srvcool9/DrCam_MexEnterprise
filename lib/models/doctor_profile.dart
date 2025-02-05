import 'dart:ffi';

import 'package:doctorcam/models/databasemodel.dart';

class DoctorProfile implements DatabaseModel {
  int? id;
  late String doctorName;
  late int mobileNumber;
  late String address;
  late String username;
  late String password;

 

  DoctorProfile({this.id, required this.doctorName,required this.mobileNumber,required this.address,required this.username,required this.password});
 // Converts the object to a Map for database storage
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'mobileNumber': mobileNumber,
      'address': address,
      'username': username,
      'password': password
    };
  }

  // Converts a Map from the database to a DoctorProfile object
  @override
  DoctorProfile fromMap(Map<String, dynamic> map) {
    return DoctorProfile(
      id: map['id'],
      doctorName: map['doctorName'],
      mobileNumber: map['mobileNumber'],
      address: map['address'],
      username: map['username'],
      password: map['password']
    );
  }


  // Returns the table name for this model
  @override
  String getTableName() {
    return 'doctor_profile';
  }
}
