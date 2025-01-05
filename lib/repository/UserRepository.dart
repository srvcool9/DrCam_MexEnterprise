import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/models/user.dart';

class Userrepository {
  final dbConfig = DatabaseConfig<User>();
  final database= DatabaseConfig().database;

  Future<int> insertUser(User user) async {
    return await dbConfig.insert(user);
  }

  // Example function to update a user
  Future<int> updateUser(User user) async {
    return await dbConfig.update(user);
  }

  Future<List<User>> getAllUsers() async {
    return await dbConfig.queryAll('users',
  (map) => User(name: '', email: '',password: '').fromMap(map),
);
  }
}
