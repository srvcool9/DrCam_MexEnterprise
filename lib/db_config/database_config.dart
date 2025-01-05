import 'dart:async';
import 'dart:io';
import 'package:doctorcam/constants/queries.dart';
import 'package:doctorcam/models/databasemodel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseConfig <T extends DatabaseModel>{

   static  Database? _database;
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
  
 

  Future<void> _onCreate(Database database, int version) async {
    await database.execute(Queries.CREATE_USER);
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
}

