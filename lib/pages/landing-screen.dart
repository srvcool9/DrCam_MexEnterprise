import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingScreen> {
  final List<Map<String, dynamic>> stats = [
    {'value': '500', 'label': 'Total patients registered', 'icon': Icons.people},
    {'value': '10', 'label': 'Patients visited this week', 'icon': Icons.calendar_today},
    {'value': '50', 'label': 'Patients visited this month', 'icon': Icons.date_range},
    {'value': '350', 'label': 'Patients visited this year', 'icon': Icons.timeline},
    {'value': '70', 'label': 'Frequently visiting patients', 'icon': Icons.repeat},
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Padding(
      padding: const EdgeInsets.all(50.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 2.0,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white, // Blue background color for each card
              borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
            ),
            child: StatCard(
              value: stat['value']!,
              label: stat['label']!,
              icon: stat['icon']!,
            ),
          );
        },
      ),
    ),
  );
}

}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36.0,
              color: Colors.teal,
            ),
            SizedBox(height: 16.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
