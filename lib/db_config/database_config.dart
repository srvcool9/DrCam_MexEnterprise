import 'dart:async';
import 'dart:io';
import 'package:doctorcam/constants/queries.dart';
import 'package:doctorcam/models/databasemodel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseConfig<T extends DatabaseModel> {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB();
      return _database!;
    }
  }

  Future<Database> initDB() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentsDir.path, "databases", "AppDb.db");

      // Ensure 'databases' directory exists
      final databasesDir = Directory(join(appDocumentsDir.path, "databases"));
      if (!await databasesDir.exists()) {
        await databasesDir.create(recursive: true);
      }

      final file = File(dbPath);
      // Check if the database exists, if not, delete the old one and create a new one
      if (!await file.exists()) {
        // If database does not exist, create it
        final winLinuxDB = await databaseFactory.openDatabase(
          dbPath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
          ),
        );
        return winLinuxDB;
      }

      // If database exists, open the existing one
      final winLinuxDB = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
      return winLinuxDB;
    } else if (Platform.isAndroid || Platform.isIOS) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, "data.db");

      // Check if the database exists, if not, create it
      final file = File(path);
      if (!await file.exists()) {
        final iOSAndroidDB = await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
        return iOSAndroidDB;
      }

      // If database exists, open the existing one
      final iOSAndroidDB = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      return iOSAndroidDB;
    }
    throw Exception("Unsupported platform");
  }

  Future<void> resetDatabase() async {
     final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentsDir.path, "databases", "AppDb.db");

    // Close and delete the existing database
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
      print('Database deleted successfully.');
    } else {
      print('No database file found to delete.');
    }

    // Reinitialize the database
    await initDB();
    print('Database reinitialized.');
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute(Queries.CREATE_USER);
    await database.execute(Queries.DOCTOR_PROFILE);
    await database.execute(Queries.PATIENTS);
    await database.execute(Queries.PATIENT_HISTORY);
  }

  Future<int> insert(T model) async {
    final db = await database;
    return await db.insert(model.getTableName(), model.toMap());
  }

  // Update a model item
  Future<int> update(T model) async {
    final db = await database;
    return await db.update(
      model.getTableName(),
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.toMap()['id']],
    );
  }

  Future<List<T>> queryAll<T>(
      String tableName, T Function(Map<String, dynamic>) fromMap) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(tableName);
    return result.map((map) => fromMap(map)).toList();
  }

  Future<List<T>> queryTopOne<T>(
    String tableName, T Function(Map<String, dynamic>) fromMap) async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    tableName,
    orderBy: 'id DESC', // Assuming 'id' is the primary key, fetch latest record
    limit: 1, // Fetch only one record
  );
  
  return result.map((map) => fromMap(map)).toList();
}
Future<T?> queryByColumn<T>(
  String tableName,
  String columnName,
  dynamic columnValue,
  T Function(Map<String, dynamic>) fromMap,
) async {
  final db = await database;

  final List<Map<String, dynamic>> result = await db.query(
    tableName,
    where: '$columnName = ?',
    whereArgs: [columnValue], // Fetch the latest matching record
    limit: 1, // Fetch only one record
  );

  if (result.isNotEmpty) {
    return fromMap(result.first) as T; // Ensure the correct type mapping
  }
  return null;
}

Future<int> updatePatient(T model) async {
    final db = await database;
    return await db.update(
      model.getTableName(),
      model.toMap(),
      where: 'patientId = ?',
      whereArgs: [model.toMap()['patientId']],
    );
  }





}
