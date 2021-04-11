import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/rounded_button.dart';
import 'package:ui/constants.dart';

final _firestore = FirebaseFirestore.instance;

class DiagnosisResultScreen extends StatefulWidget {
  static String id = 'diagnosisResultScreen';

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
    var height = screenSize.height;
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
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: Text(
                "E-Ophthalmologist",
                style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
              ),
            ),
            backgroundColor: Colors.indigo,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Diagnosis",
                  style: kTextStyle.copyWith(fontSize: 30.0),
                  textAlign: TextAlign.center,
                ),
                Center(
                  child: CachedNetworkImage(
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
                      width: width / 2,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                    ),
                    imageUrl: arguments['image_url'],
                    width: width,
                    height: height / 2.2,
                  ),
                ),
                _commonLabelText(
                    sentence: "Scan on: $datetime",
                    textColor: Colors.black,
                    fontSize: 20.0),
                _commonLabelText(
                    sentence:
                        "A ${arguments['result']} condition has been detected in the above retinal fundus",
                    textColor: Colors.red,
                    fontSize: 20.0),
                _commonLabelText(
                    sentence:
                        "This is a dummy treatment message, user will get a treatment and necessary details about this type of diabetic retinopathy here",
                    textColor: Colors.black54,
                    fontSize: 15.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RoundedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    colour: Colors.indigo,
                    title: "Back to Home",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _commonLabelText(
      {@required String sentence,
      @required Color textColor,
      @required fontSize}) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            "$sentence",
            style: kTextStyle.copyWith(color: textColor, fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 50,
        )
      ],
    );
  }
}
