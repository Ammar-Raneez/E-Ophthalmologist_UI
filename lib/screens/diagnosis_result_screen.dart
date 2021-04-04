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
    String datetime = DateTime.fromMillisecondsSinceEpoch(
                arguments['time'].seconds * 1000)
            .day
            .toString() +
        "-" +
        DateTime.fromMillisecondsSinceEpoch(arguments['time'].seconds * 1000)
            .month
            .toString() +
        "-" +
        DateTime.fromMillisecondsSinceEpoch(arguments['time'].seconds * 1000)
            .year
            .toString();

    return Container(
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: CachedNetworkImage(
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            SizedBox(
                              width: width/2,
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress),
                              ),
                            ),
                    imageUrl: arguments['image_url'],
                    width: width,
                    height: 350,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Scan on: $datetime",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Poppins-SemiBold",
                        color: Colors.red),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "A ${arguments['result']} condition has been detected in the above retinal fundus",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Poppins-SemiBold"),
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
                RoundedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  colour: Color(0xff01CDFA),
                  title: "Back to Home",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
