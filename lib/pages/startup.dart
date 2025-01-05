import 'dart:io';

import 'package:doctorcam/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Startup extends StatefulWidget{
  
  @override
  StartupState createState() => StartupState();
}

class StartupState extends State<Startup> {
   @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showConfirmationDialog(context); // Correct use of BuildContext
    });
  }

  void _showConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Please confirm if the database file exists at C:/Users/{profile}/Documents/databases/AppDb.db. Do you want to start the application?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
              child: Text("Exit"),
            ),
            TextButton(
              onPressed: () {
                showSuccessNotification(context, "New database file will be created if not exists");
       Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
              },
              child: Text("Start"),
            ),
          ],
        );
      },
    );

    if (result == false || result == null) {
      if (Platform.isWindows) {
        exit(0); // Exit for Windows
      } else if (Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop(); // Exit for mobile platforms
      }
    }
  }

  
void showSuccessNotification(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50, // Distance from the top
      right: 20, // Distance from the right edge
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 90, 150), // Background color
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(66, 0, 0, 0),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white), // Success icon
              SizedBox(width: 8), // Space between icon and text
              Text(
                message,
                style: TextStyle(color: Colors.white), // White text color
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // Insert the overlay entry
  overlay?.insert(overlayEntry);

  // Remove the overlay after a delay
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: Center(
        child: Text("Application Started!"),
      ),
    );
  }
}