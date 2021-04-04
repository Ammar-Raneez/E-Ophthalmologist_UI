import 'package:flutter/material.dart';
import 'package:ui/screens/add_report_screen.dart';
import 'package:ui/screens/current_screen.dart';
import 'package:ui/screens/diagnosis_result_screen.dart';
import 'package:ui/screens/diagnosis_screen.dart';
import 'package:ui/screens/edit_profile_screen.dart';
import 'package:ui/screens/blog_screen.dart';
import 'package:ui/screens/edit_report_screen.dart';
import 'package:ui/screens/home_screen.dart';
import 'package:ui/screens/login_screen.dart';
import 'package:ui/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ui/screens/report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: LoginScreen(),

      initialRoute: LoginScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        BlogScreen.id: (context) => BlogScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        CurrentScreen.id: (context) => CurrentScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        DiagnosisScreen.id: (context) => DiagnosisScreen(),
        ReportScreen.id: (context) => ReportScreen(),
        AddReportScreen.id: (context) => AddReportScreen(),
        EditReportScreen.id: (context) => EditReportScreen(),
        DiagnosisResultScreen.id: (context) => DiagnosisResultScreen(),
        EditProfileScreen.id: (context) => EditProfileScreen(),
      },
    );
  }
}