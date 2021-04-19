import 'package:flutter/material.dart';
import 'package:ui/screens/add_family_member.dart';
import 'package:ui/screens/blog_screen/all_blogs_screen.dart';
import 'package:ui/screens/blog_screen/each_blog_type_screen.dart';
import 'package:ui/screens/blog_screen/specific_blog_screen.dart';
import 'package:ui/screens/current_screen.dart';
import 'package:ui/screens/diagnosis_result_screen.dart';
import 'package:ui/screens/diagnosis_screen.dart';
import 'package:ui/screens/edit_profile_screen.dart';
import 'package:ui/screens/home_screen.dart';
import 'package:ui/screens/login_screen.dart';
import 'package:ui/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ui/screens/reports_and_appointment/add_appointment_screen.dart';
import 'package:ui/screens/reports_and_appointment/add_report_screen.dart';
import 'package:ui/screens/reports_and_appointment/edit_appointment_screen.dart';
import 'package:ui/screens/reports_and_appointment/edit_report_screen.dart';
import 'package:ui/screens/reports_and_appointment/report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // first page to show
      home: LoginScreen(),
      initialRoute: LoginScreen.id,
      // all screen routes
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        AllBlogsScreen.id: (context) => AllBlogsScreen(),
        EachBlogTypeScreen.id: (context) => EachBlogTypeScreen(),
        SpecificBlogScreen.id: (context) => SpecificBlogScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        CurrentScreen.id: (context) => CurrentScreen(),
        DiagnosisScreen.id: (context) => DiagnosisScreen(),
        DiagnosisResultScreen.id: (context) => DiagnosisResultScreen(),
        ReportScreen.id: (context) => ReportScreen(),
        AddReportScreen.id: (context) => AddReportScreen(),
        EditReportScreen.id: (context) => EditReportScreen(),
        AddAppointmentScreen.id: (context) => AddAppointmentScreen(),
        EditAppointmentScreen.id: (context) => EditAppointmentScreen(),
        EditProfileScreen.id: (context) => EditProfileScreen(),
        AddFamilyMemberScreen.id: (context) => AddFamilyMemberScreen()
      },
    );
  }
}
