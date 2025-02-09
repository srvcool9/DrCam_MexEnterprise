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
        agencyName TEXT NOT NULL,
        contactNumber INTEGER NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      );
''';

static const String PATIENTS = '''
     CREATE TABLE IF NOT EXISTS patients (
        patientId INTEGER PRIMARY KEY,
        patientName TEXT NOT NULL,
        gender TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL
      );
''';

static const String PATIENT_HISTORY = '''
     CREATE TABLE IF NOT EXISTS patient_history (
        id INTEGER PRIMARY KEY,
        patientId INTEGER NOT NULL,
        appointmentDate TEXT NOT NULL,
        createdOn REAL NOT NULL
      );
''';
}
