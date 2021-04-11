import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/home_page_icon_content.dart';
import 'package:ui/components/home_page_reusable_card.dart';
import 'package:ui/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ui/screens/diagnosis_result_screen.dart';

final _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  static String id = "homeScreen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDetails;

  static String bmi = "";
  static String a1c = "";
  static String ldl = "";
  static String hdl = "";
  var gender;
  var dm;
  var smoker;

  // user eye scans
  bool haveScans = true;
  var eyeScans = [];

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  // get current user details
  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();
    var tempScans = [];

    // get all the scans done by this user
    await document.reference.collection("eye-scans").get().then((value) => {
          value.docs.forEach((element) {
            tempScans.add(element.data());
          })
        });

    setState(() {
      userDetails = document.data();
      // act as a toggle
      haveScans = tempScans.length != 0 ? true : false;
    });

    setState(() {
      bmi = userDetails['BMI'];
      a1c = userDetails['A1C'];
      ldl = userDetails['LDL'];
      hdl = userDetails['HDL'];
      dm = userDetails['DM Type'];
      gender = userDetails['gender'];
      smoker = userDetails['smoker'];

      //Enum value is stored, use ternary to get only the Gender value
      gender = gender.toString() == "Gender.Male" ? "Male" : "Female";
      smoker = smoker.toString() == "Smoker.Yes" ? "Yes" : "No";
      dm = dm.toString() == "DMType.Type1" ? "Type I" : "Type II";
      eyeScans = tempScans;
    });
  }

  Expanded iconCard(IconData icon, String label, String value) {
    return Expanded(
      child: HomePageReusableCard(
        color: Colors.white,
        cardContent: HomePageIconContent(label, value, icon),
      ),
    );
  }

  Expanded regularCard(String label, int val) {
    return Expanded(
      child: HomePageReusableCard(
        color: Colors.white,
        cardContent: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              label,
              style: kTextStyle,
            ),
            Text(
              val.toString(),
              style: kTextStyle.copyWith(fontSize: 30, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        // if there are scans, but not fetched yet, display a spinner
        child: haveScans && eyeScans.length == 0
            ? Align(
                child: CircularProgressIndicator(),
                alignment: Alignment.center,
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 70.0,
                    ),
                    CircularPercentIndicator(
                      radius: 300.0,
                      lineWidth: 50.0,
                      percent: 0.9,
                      center: Text(
                        "90%\nRisk",
                        style: kTextStyle.copyWith(
                          fontSize: 30.0,
                          color: Color(0xffdd0000),
                        ),
                      ),
                      arcType: ArcType.HALF,
                      progressColor: Color(0xffdd0000),
                    ),
                    Row(
                      children: <Widget>[
                        gender == "Male"
                            ? iconCard(
                                FontAwesomeIcons.mars,
                                "GENDER",
                                gender.toString(),
                              )
                            : iconCard(
                                FontAwesomeIcons.venus,
                                "GENDER",
                                gender.toString(),
                              ),
                        iconCard(
                          FontAwesomeIcons.eye,
                          "TYPE",
                          dm.toString(),
                        ),
                        iconCard(
                            FontAwesomeIcons.calendar, "DURATION", "6 Years"),
                        smoker == "No"
                            ? iconCard(
                                FontAwesomeIcons.smokingBan,
                                "SMOKER?",
                                smoker.toString(),
                              )
                            : iconCard(
                                FontAwesomeIcons.smoking,
                                "SMOKER?",
                                smoker.toString(),
                              ),
                      ],
                    ),
                    _commonHorizontalCard(
                        title: 'BMI', unit: 'kg/m2', val: bmi),
                    _commonHorizontalCard(
                        title: 'A1C', unit: 'mmol/mol', val: a1c),
                    _commonHorizontalCard(
                        title: 'LDL', unit: 'mg/dL', val: ldl),
                    _commonHorizontalCard(
                        title: 'HDL', unit: 'mg/dL', val: hdl),
                    eyeScans.length == 0
                        // if there are not any scans do not show this section
                        ? Container(
                            width: 0,
                            height: 0,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, bottom: 10.0, left: 8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Past Scans",
                                style: kTextStyle.copyWith(
                                    color: Colors.indigo, fontSize: 25),
                              ),
                            ),
                          ),
                    eyeScans.length == 0
                        // if there are not any scans do not show this section
                        ? Container(
                            width: 0,
                            height: 0,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: SizedBox(
                              height: 250.0,
                              child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: eyeScans.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        GestureDetector(
                                  onTap: () {
                                    // pass the specific scan details to diagnosis result screen
                                    var argsForResult = {
                                      'result': eyeScans[index]['result'],
                                      'image_url': eyeScans[index]['image_url'],
                                      'time': eyeScans[index]['timestamp']
                                    };
                                    Navigator.pushNamed(
                                        context, DiagnosisResultScreen.id,
                                        arguments: argsForResult);
                                  },
                                  child: Card(
                                    child: Container(
                                      height: 100,
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            // while image downloads, display a spinner
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                SizedBox(
//                                              width: width / 2,
                                              height: 50,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress),
                                              ),
                                            ),
                                            imageUrl: eyeScans[index]
                                                ['image_url'],
                                            height: 100,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.8,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Date: " +
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                                eyeScans[index][
                                                                            'timestamp']
                                                                        .seconds *
                                                                    1000)
                                                            .day
                                                            .toString() +
                                                        "-" +
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                                eyeScans[index][
                                                                            'timestamp']
                                                                        .seconds *
                                                                    1000)
                                                            .month
                                                            .toString() +
                                                        "-" +
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                                eyeScans[index][
                                                                            'timestamp']
                                                                        .seconds *
                                                                    1000)
                                                            .year
                                                            .toString(),
                                                    style: kTextStyle,
                                                  ),
                                                  Text(
                                                    "Condition: " +
                                                        eyeScans[index]
                                                                ['result']
                                                            .toString()
                                                            .toUpperCase(),
                                                    style: kTextStyle.copyWith(
                                                        fontSize: 11.0),
                                                  ),
                                                ],
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
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  HomePageReusableCard _commonHorizontalCard(
      {@required title, @required unit, @required val}) {
    return HomePageReusableCard(
      color: Colors.white,
      cardContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: kTextStyle.copyWith(color: Colors.indigo, fontSize: 25),
          ),
          SizedBox(
            height: 25.0,
          ),
          Text(
            unit,
            style: kTextStyle.copyWith(fontSize: 15),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            val.toString(),
            style: kTextStyle.copyWith(fontSize: 30, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
