import 'package:doctorcam/models/doctor_profile.dart';
import 'package:doctorcam/repository/DoctorProfileRepository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  late Doctorprofilerepository doctorprofilerepository;
  late DoctorProfile doctorProfile;
  String _agencyName = '';

  bool showActivationKey = true; // Added variable
  String _deviceId = ''; // Added variable

  @override
  void initState() {
    super.initState();
    doctorprofilerepository = Doctorprofilerepository();
    getAgencyName();
    _generateDeviceId(); // Added device ID generation
  }

  void _generateDeviceId() {
    final uuid = Uuid();
    setState(() {
      _deviceId = uuid.v1();
    });
  }

  void activationKeyVisibility() {
    setState(() {
      showActivationKey = !showActivationKey;
    });
  }

  void showErrorNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> getAgencyName() async {
    DoctorProfile? doctor =
        await doctorprofilerepository.getFirstDoctorProfile();

    setState(() {
      _agencyName = doctor?.agencyName ?? "Doctor's Agency Name";
    });
  }

  void showSuccessNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF005A96),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(66, 0, 0, 0),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username == 'admin') {
      if (password == 'admin') {
        showSuccessNotification(context, "Welcome to our application");
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        showErrorNotification(
            context, "Invalid Credentials! Please try again.");
      }
    } else {
      Future<DoctorProfile?> persist =
          doctorprofilerepository.getFirstDoctorProfile();
      final doctor = await persist;
      if (doctor?.password == password) {
        showSuccessNotification(context, "Welcome to our application");
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        showErrorNotification(
            context, "Invalid Credentials! Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Side: Text and Form
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        _agencyName.isNotEmpty ? _agencyName : "Mex Enterprise",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: "UserName",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: login, // Updated to use the login method
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right Side: Image
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    'assets/background.gif', // Replace with the correct path to your illustration
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
