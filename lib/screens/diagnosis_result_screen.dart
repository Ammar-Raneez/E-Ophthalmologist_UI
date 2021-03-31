import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class DiagnosisResultScreen extends StatefulWidget {
  static String id = 'diagnosis_result_screen';

  @override
  _DiagnosisResultScreenState createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDetails;
  String email;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    setState(() {
      userDetails = document.data();
      print(userDetails);
    });

    setState(() {
      email = userDetails['userEmail'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    return Container(
      child: Text(arguments.toString()),
    );
  }
}
