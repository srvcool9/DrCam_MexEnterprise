class Queries {
  static const String CREATE_USER = '''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT
      );
    ''';

  static const String DOCTOR_PROFILE = '''
     CREATE TABLE IF NOT EXISTS doctor_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        agencyName TEXT NOT NULL,
        contactNumber INTEGER NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      );
''';

  static const String PATIENTS = '''
     CREATE TABLE IF NOT EXISTS patients (
        patientId INTEGER PRIMARY KEY AUTOINCREMENT,
        patientName TEXT NOT NULL,
        gender TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL
      );
''';

  static const String PATIENT_HISTORY = '''
     CREATE TABLE IF NOT EXISTS patient_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        appointmentDate TEXT NOT NULL,
        createdOn TEXT NOT NULL
      );
''';

  static const String GET_LAST_APPOINTMENT = '''
     select * from patient_history ph
     where ph.patientId = ?
     order by createdOn
     limit 1
     ''';

  static const String GET_GRID_DATA = '''
  select distinct ph.patientId ,p.patientName,t.appointmentDate as lastVisited
  from patient_history ph 
  inner join patients p on p.patientId = ph.patientId 
  left join(
   select *
   from patient_history ph 
   order by id DESC 
   limit 1
  ) t on t.patientId =p.patientId 
  ''';

  static const String GET_PATIENT_APOINTMENT_DATES = ''' 
   SELECT DISTINCT strftime('%d/%m/%Y', ph.appointmentDate) AS appointment_date
   FROM patient_history ph
   WHERE ph.patientId = ?;
  ''';
}
