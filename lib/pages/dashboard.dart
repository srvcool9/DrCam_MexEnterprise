import 'package:doctorcam/pages/camera.dart';
import 'package:doctorcam/pages/doctor-profile-screen.dart';
import 'package:doctorcam/pages/landing-screen.dart';
import 'package:doctorcam/pages/login.dart';
import 'package:doctorcam/pages/patient-history-screen';
import 'package:doctorcam/pages/pdfexamplescreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LandingScreen(),
    Camera(),
    PatientHistoryScreen(),
    DoctorProfileScreen(),
    PDFExampleScreen(),
    ExitPage(onExit: () {
      exit(0);
    }),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Make the navbar taller
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo and company name
            Row(
              children: [
                Text(
                  'Mex',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Technologies',
                  style: TextStyle(
                    color: Colors.teal.shade400,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            // Navigation menu
            Row(
              children: [
                _buildNavItem('Home', 0),
                _buildNavItem('Camera', 1),
                _buildNavItem('Patient History', 2),
                _buildNavItem('Settings', 3),
              ],
            ),
            // Logout button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Logout button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildNavItem(String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: isSelected ? Colors.teal : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class ExitPage extends StatelessWidget {
  final VoidCallback onExit;

  const ExitPage({Key? key, required this.onExit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onExit,
        child: const Text('Exit App'),
      ),
    );
  }
}
