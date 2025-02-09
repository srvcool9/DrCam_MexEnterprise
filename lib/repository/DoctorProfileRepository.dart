import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/models/doctor_profile.dart';

class Doctorprofilerepository {
  final dbConfig = DatabaseConfig<DoctorProfile>();
  final database = DatabaseConfig().database;

  Future<int> insertDoctorProfile(DoctorProfile doctorProfile) async {
    return await dbConfig.insert(doctorProfile);
  }

  // Example function to update a user
  Future<int> updateDoctorProfile(DoctorProfile doctorProfile) async {
    return await dbConfig.update(doctorProfile);
  }

  Future<List<DoctorProfile>> getAllDoctorProfile() async {
    // Fetch all rows from the 'doctor_profile' table
    return await dbConfig.queryAll(
        'doctor_profile',
        (map) => DoctorProfile(
                agencyName: '', contactNumber: 0, email: '', password: '')
            .fromMap(map));
  }

  Future<DoctorProfile?> getFirstDoctorProfile() async {
    final result = await dbConfig.queryTopOne(
        'doctor_profile',
        (map) => DoctorProfile(
                id:0 ,agencyName: '', contactNumber: 0, email: '', password: '')
            .fromMap(map));
    return result.isNotEmpty ? result.first : null;
  }
}
