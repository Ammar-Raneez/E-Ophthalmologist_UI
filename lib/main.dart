import 'package:flutter/material.dart';
import 'package:ui/screens/current_screen.dart';
import 'package:ui/screens/diagnosis_screen.dart';
import 'package:ui/screens/edit_profile.dart';
import 'package:ui/screens/blog_screen.dart';
import 'package:ui/screens/login_screen.dart';
import 'package:ui/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';

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
        BlogScreen.id: (context) => BlogScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        CurrentScreen.id: (context) => CurrentScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        DiagnosisScreen.id: (context) => DiagnosisScreen(),
        EditProfileScreen.id: (context) => EditProfileScreen(),
      },
    );
  }
}