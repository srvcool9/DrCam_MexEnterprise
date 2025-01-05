abstract class DatabaseModel {
  Map<String, dynamic> toMap();
  String getTableName();
  DatabaseModel fromMap(Map<String, dynamic> map);
}
