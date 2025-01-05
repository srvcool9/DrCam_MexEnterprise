import 'package:flutter/material.dart';

class Login extends StatefulWidget{

  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login>{

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username == 'admin' && password == 'admin') {
      showSuccessNotification(context, "Welcome to our application");
       Navigator.pushReplacementNamed(context, '/dashboard'); 

    } else {
      showErrorNotification(context, "Invalid Credentials! Please try again.");
    }
  }

  void showErrorNotification(BuildContext context, String message) {
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
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red, width: 1.5), // Red border
            boxShadow: [
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
              Icon(Icons.error, color: Colors.red), // Error icon
              SizedBox(width: 8), // Space between icon and text
              Text(
                message,
                style: TextStyle(color: Colors.red), // Red text color
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
            color:  Color.fromARGB(255, 0, 90, 150), // Background color
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:  Color.fromARGB(66, 0, 0, 0),
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
      body: Row(
        children: [
          // Left side - Image
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/doc.jpg'), // Ensure this image exists
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Right side - Login form
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: login, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}