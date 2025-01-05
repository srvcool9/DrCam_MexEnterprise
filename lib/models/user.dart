import 'package:doctorcam/models/databasemodel.dart';

class User implements DatabaseModel {
  int? id;
  String name;
  String email;
  String password;

  User({this.id, required this.name, required this.email,required this.password});

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password
    };
  }

  @override
  String getTableName() {
    return 'users';
  }

  // fromMap method: Converts a Map to a User object
  @override
   User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password']
    );
  }
}
