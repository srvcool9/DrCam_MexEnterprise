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
    SELECT 
    p.patientId,
    p.patientName,
    MAX(t.appointmentDate) AS lastVisited
    FROM patients p
    LEFT JOIN patient_history t 
    ON t.patientId = p.patientId
    GROUP BY p.patientId, p.patientName
  ''';

  static const String GET_PATIENT_APOINTMENT_DATES = '''
   SELECT DISTINCT strftime('%d/%m/%Y', ph.appointmentDate) AS appointment_date
   FROM patient_history ph
   WHERE ph.patientId = ?;
  ''';

  static const String PATIENT_IMAGES = '''
      CREATE TABLE IF NOT EXISTS patient_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        historyId INTEGER NOT NULL,
        imageBase64 TEXT NOT NULL,
        createdOn TEXT NOT NULL
      );
  ''';

  static const String PATIENT_VIDEOS = '''
      CREATE TABLE IF NOT EXISTS patient_videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        historyId INTEGER NOT NULL,
        videoPath TEXT NOT NULL,
        createdOn TEXT NOT NULL
      );
  ''';

  static const String GET_PATIENT_IMAGES_BY_PATIENT_ID = '''
   select * 
   from patient_images
   pi where pi.patientId =?

  ''';

  static const String GET_PATIENT_VIDEOS_BY_PATIENT_ID = '''
   select * 
   from patient_videos
   pi where pi.patientId =?

  ''';

  static const String GET_TOTAL_REGISTERED_PATIENTS = '''
   select count(p.patientId) as TotalRegistered
   from patients p 
  ''';

  static const String GET_PATIENTS_COUNT_VISITED_CURRENT_WEEK = '''
   select count(distinct p.patientId) as VisitedThisWeek
   from patients p 
   inner join patient_history ph 
   on ph.patientId =p.patientId 
   where ((strftime('%d', 'now') - 1) / 7 + 1) = ((strftime('%d', ph.appointmentDate) - 1) / 7 + 1)
  ''';

  static const String GET_PATIENTS_COUNT_VISITED_CURRENT_MONTH = '''
   select count(distinct p.patientId) as VisitedThisMonth
   from patients p 
   inner join patient_history ph 
   on ph.patientId =p.patientId 
   where strftime('%m', 'now') = strftime('%m', ph.appointmentDate)
  ''';

  static const String GET_PATIENTS_COUNT_VISITED_CURRENT_YEAR = '''
   select count(distinct p.patientId) as VisitedThisMonth
   from patients p 
   inner join patient_history ph 
   on ph.patientId =p.patientId 
   where strftime('%m', 'now') = strftime('%m', ph.appointmentDate)
  ''';
}
