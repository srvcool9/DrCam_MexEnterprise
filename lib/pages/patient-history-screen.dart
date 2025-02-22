import 'package:doctorcam/dto/PatientHistoryDTO.dart';
import 'package:doctorcam/pages/dashboard.dart';
import 'package:doctorcam/repository/PatientHistoryRepository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class PatientHistoryScreen extends StatefulWidget {
  @override
  _PatientHistoryScreenState createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  List<PatientHistoryDto> patientData = [];
  late Patienthistoryrepository patienthistoryrepository;

  @override
  void initState() {
    super.initState();
    patienthistoryrepository = Patienthistoryrepository();
    patienthistoryrepository.getGridData().then((data) {
      setState(() {
        patientData = data;
      });
    });
  }

void generatePdf(BuildContext context,int patientId){

     final dashboardState = context.findAncestorStateOfType<DashboardState>();
      if (dashboardState != null) {
      dashboardState.setState(() {
        dashboardState.selectedIndex = 5; // Index of PDFExampleScreen
        dashboardState.patientId=patientId!;
      });
    }
   }

void _viewHistory(BuildContext context, int patientId) async {
  List<String> dateStrings = await patienthistoryrepository.getPreviousApointment(patientId);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Appointment Dates",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: SizedBox(
          width: 300,
          height: 300, 
          child: dateStrings.isNotEmpty
              ? ListView.builder(
                  itemCount: dateStrings.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        dateStrings[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(); 
                      },
                    );
                  },
                )
              : const Center(child: Text("No Previous Appointments")),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.teal.shade100, width: 0.5),
                outside: BorderSide(color: Colors.teal, width: 1.5),
              ),
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                _buildHeaderRow(),
                if (patientData.isNotEmpty)
                  ...patientData.map((patient) => _buildDataRow(patient,context))
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.teal),
      children: [
        tableHeaderCell('Patient ID'),
        tableHeaderCell('Patient name'),
        tableHeaderCell('Last visited'),
        tableHeaderCell('Visit history'),
        tableHeaderCell('Generate PDF'),
      ],
    );
  }

  TableRow _buildDataRow(PatientHistoryDto patient, BuildContext context) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent.shade100, width: 0.5),
      ),
      children: [
        tableCell(patient.patientId.toString()),
        tableCell(patient.patientName),
        tableCell(patient.lastVisited),
        IconButton(
          icon: const Icon(Icons.visibility, color: Colors.teal),
          onPressed: () {
            _viewHistory(context, patient.patientId);
          },
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          onPressed: () {
            generatePdf(context, patient.patientId);
          },
        ),
      ],
    );
  }

Widget tableHeaderCell(String label) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.teal, // Background color for header
      borderRadius: BorderRadius.circular(12.0), // Rounded corners
    ),
    padding: const EdgeInsets.all(12.0),
    alignment: Alignment.center,
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}
Widget tableCell(String? value, {bool isHeader = false, bool isFirst = false, bool isLast = false}) {
  return Container(
    decoration: BoxDecoration(
      color: isHeader ? Colors.teal : Colors.transparent, // Header color
      borderRadius: isHeader
          ? BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(12.0) : Radius.zero,
              topRight: isLast ? const Radius.circular(12.0) : Radius.zero,
            )
          : BorderRadius.zero, // No border radius for regular cells
    ),
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
    alignment: Alignment.center,
    child: Text(
      value ?? '',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14.0,
        color: isHeader ? Colors.white : Colors.black, // White text for header
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
}

}