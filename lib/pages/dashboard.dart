import 'package:doctorcam/pages/camera.dart';
import 'package:doctorcam/pages/patients.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Patients(),
      Camera(),
      ExitPage(onExit: () {
        exit(0);
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.grey.shade500,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                // Load image from assets
                SizedBox(
                  height: 100,
                  width: 110,
                  child: Image.asset(
                    'assets/DrCam_Icon.png', // Path to the image in the assets folder
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16), // Spacing below the logo
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.health_and_safety),
                label: Text('Patients'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.camera),
                label: Text('Camera'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.exit_to_app),
                label: Text('Exit'),
              ),
            ],
          ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
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
        onPressed: () {
          // Exit the application directly
          exit(0);
        },
        child: const Text('Exit App'),
      ),
    );
  }
}
