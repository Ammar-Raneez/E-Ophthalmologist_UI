import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/rounded_button.dart';
import 'package:ui/screens/home_screen.dart';

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
    var screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    return Container(
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: CachedNetworkImage(
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(value: downloadProgress.progress),
                    imageUrl: arguments['image_url'],
                    width: width,
                    height: 400,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "A ${arguments['result']} condition has been detected in the above retinal fundus",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Poppins-SemiBold"
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                RoundedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, HomeScreen.id);
                  },
                  colour: Color(0xff01CDFA),
                  title: "Back to Home",
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
