import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/models/user.dart';
import 'package:doctorcam/repository/UserRepository.dart';
import 'package:flutter/material.dart';

class Patients extends StatefulWidget{

 const Patients({super.key});

 @override
 PatientState createState() => PatientState();

}

class PatientState extends State<Patients>{
 late DatabaseConfig _dbHelper;
  final List<Map<String, dynamic>> data = [
    {"ID": 1, "Name": "John", "Age": 25, "City": "New York"},
    {"ID": 2, "Name": "Emma", "Age": 30, "City": "London"},
    {"ID": 3, "Name": "Sophia", "Age": 22, "City": "Paris"},
    {"ID": 4, "Name": "Liam", "Age": 28, "City": "Tokyo"},
  ];
  
  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseConfig();
    var userRepo= new Userrepository();
      Future<List<User>> userList=userRepo.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: Center(
        child: Container(
          width: 800, // Adjusted width
          height: 400, // Adjusted height
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 20, // Adjust space between columns
              columns: const [
                DataColumn(
                  label:
                      Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Name',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Age',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('City',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: data.map((row) {
                return DataRow(cells: [
                  DataCell(Text(row['ID'].toString())),
                  DataCell(Text(row['Name'])),
                  DataCell(Text(row['Age'].toString())),
                  DataCell(Text(row['City'])),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}