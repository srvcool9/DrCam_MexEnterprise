class Queries {
  static const String CREATE_USER = '''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT
      );
    ''';

  static const String DOCTOR_PROFILE = '''
     CREATE TABLE IF NOT EXISTS doctor_profile (
        id INTEGER PRIMARY KEY,
        doctorName TEXT NOT NULL,
        mobileNumber INTEGER NOT NULL,
        address TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      );
''';
}
