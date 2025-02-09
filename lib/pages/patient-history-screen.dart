import 'package:flutter/material.dart';
import 'package:path/path.dart';

class PatientHistoryScreen extends StatefulWidget {
  @override
  _PatientHistoryScreenState createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  List<Map<String, dynamic>> patientData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient History',
            style: TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Table(
              border: TableBorder.all(color: Colors.blueAccent),
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.teal),
                  children: [
                    tableHeaderCell('Patient ID'),
                    tableHeaderCell('Patient name'),
                    tableHeaderCell('Last visited'),
                    tableHeaderCell('Visit history'),
                    tableHeaderCell('Generate PDF'),
                  ],
                ),
                ...patientData.map((patient) => TableRow(
                      children: [
                        tableCell(patient['id']),
                        tableCell(patient['name']),
                        tableCell(patient['lastVisited']),
                        IconButton(
                          icon: Icon(Icons.visibility, color: Colors.teal),
                          onPressed: () {
                            // Implement view history functionality
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                          onPressed: () {
                            // Implement PDF generation functionality
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tableHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget tableCell(String? value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.0),
      ),
    );
  }
}
