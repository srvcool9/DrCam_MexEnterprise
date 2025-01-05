import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/pages/dashboard.dart';
import 'package:doctorcam/pages/login.dart';
import 'package:doctorcam/pages/startup.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dbConfig= DatabaseConfig();
  await dbConfig.initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown, // Define the theme here
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
    routes: {
      '/': (context) => Startup(),
      '/login': (context) => const Login(),
      '/dashboard': (context) => const Dashboard()
    },
    );
  }
}
