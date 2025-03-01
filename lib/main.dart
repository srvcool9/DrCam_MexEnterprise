import 'dart:async';
import 'dart:io';
import 'package:doctorcam/db_config/database_config.dart';
import 'package:doctorcam/pages/camera.dart';
import 'package:doctorcam/pages/dashboard.dart';
import 'package:doctorcam/pages/doctor-profile-screen.dart';
import 'package:doctorcam/pages/login.dart';
import 'package:doctorcam/pages/landing-screen.dart';
import 'package:doctorcam/pages/pdfexamplescreen.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dbConfig= DatabaseConfig();
  await dbConfig.initDB();
   FFmpegKitConfig.setEnvironmentVariable(
      "FFMPEG_BIN", "windows/ffmpeg-plugin/bin/ffmpeg.exe");
  FFmpegKitConfig.setEnvironmentVariable(
      "FFPROBE_BIN", "windows/ffmpeg-plugin/bin/ffprobe.exe");
  runApp(const MyApp());
  }, (error, stackTrace) {
    File('error.log').writeAsStringSync('$error\n$stackTrace');
  });
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
      '/': (context) => const Login(),
      '/home':(context)=> const DoctorProfileScreen(),
      '/dashboard': (context) => const Dashboard(),
      '/camera':(context) => Camera(),
      '/pdf':(context)=> PDFExampleScreen()
      
    },
    );
  }
}
