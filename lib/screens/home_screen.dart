import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/home_page_icon_content.dart';
import 'package:ui/components/home_page_reusable_card.dart';
import 'package:ui/constants.dart';
import 'package:intl/intl.dart';
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
  Dio dio = new Dio();
  User user = FirebaseAuth.instance.currentUser;
  var userDocument;
  var currentUserDetails;
  var mainUserDetails;

  static String bmi = "";
  static String a1c = "";
  static String systolic = "";
  static String diastolic = "";
  static String duration = "";

  // uncomment when needed
  static String riskDescription = "";
  static String riskValue = "";

  // comment this when main needed
//  static String riskDescription =
//      "You have a low risk of developing sight threatening retinopathy";
//  static String riskValue = "20";

  var diagnosis;
  var gender;
  var dm;
  var smoker;

  // user eye scans
  bool haveScans = true;
  var eyeScans = [];

  // eye scan reports bg image
  var eyeScanBgImage = ["images/search.png"];

  bool showSpinner = false;

  // for coloring based on risk percentage
  Color riskColor;

  @override
  void initState() {
    super.initState();
    getUserDetails();

    // uncomment when needed
    getRisk();
  }

  // get the actual users document (family members document or main user)
  getActualUserDocument() async {
    var document = await _firestore.collection("users").doc(user.email).get();
    mainUserDetails = document.data();

    if (mainUserDetails['currentFamilyMember'] == '') {
      setState(() {
        userDocument = document;
      });
    } else {
      var tempUserDocument = await _firestore
          .collection("users")
          .doc(user.email)
          .collection('family')
          .doc(mainUserDetails['currentFamilyMember'])
          .get();
      setState(() {
        userDocument = tempUserDocument;
      });
    }
  }

  // get current user details
  getUserDetails() async {
    await getActualUserDocument();
    var tempScans = [];

    // get all the scans done by this user
    await userDocument.reference.collection("eye-scans").get().then((value) => {
          value.docs.forEach((element) {
            tempScans.add(element.data());
          })
        });

    setState(() {
      currentUserDetails = userDocument.data();
      // act as a toggle
      haveScans = tempScans.length != 0 ? true : false;
    });

    setState(() {
      bmi = currentUserDetails['BMI'];
      a1c = currentUserDetails['A1C'];
      systolic = currentUserDetails['systolic'];
      diastolic = currentUserDetails['diastolic'];
      duration = currentUserDetails['Duration'];
      dm = currentUserDetails['DM Type'];
      gender = currentUserDetails['gender'];
      diagnosis = currentUserDetails['Diagnosis'];
      smoker = currentUserDetails['smoker'];

      //Enum value is stored, use ternary to produce normal strings
      gender = gender.toString() == "Gender.Male" ? "Male" : "Female";
      smoker = smoker.toString() == "Smoker.Yes" ? "Yes" : "No";
      dm = dm.toString() == "DMType.Type1" ? "Type I" : "Type II";
      diagnosis = diagnosis.toString() == "Diagnosis.Yes" ? "1" : "0";

      eyeScans = tempScans;
    });
  }

  getRisk() async {
    // must login and get authorization string beforehand
    Response loginResponse = await dio.post(
        "https://api.retinarisk.com/api/auth/sign-in",
        data: {"email": "ammarraneez@gmail.com", "password": "Ammarraneez12"});

    // send all required data to API endpoint to get the required risk
    Response riskResponse = await dio.post(
        "https://api.retinarisk.com/api/calculator/calculaterisk",
        data: {
          "data": {
            "diabetesDuration": duration,
            "diabetesType": dm == "Type I" ? "type1" : "type2",
            "gender": gender == "Female" ? "female" : "male",
            "hasRetinopathy": diagnosis,
            "bloodGlucose": a1c,
            "bloodPressures": {"diastolic": diastolic, "systolic": systolic}
          },
          "options": {"format": "json", "language": "en"}
        },
        options: Options(
            headers: {"Authorization": loginResponse.data['access_token']}));

    setState(() {
      riskValue = (riskResponse.data['results']['RiskValue'] * 10).toString();
      riskDescription =
          riskResponse.data['results']['Analysis']['riskValue']['text'];

      // just a coloring for the risk and percentage indicator
      if (double.parse(riskValue) < 30.0) {
        riskColor = Colors.lightGreenAccent;
      } else if (double.parse(riskValue) < 50) {
        riskColor = Colors.yellow;
      } else if (double.parse(riskValue) < 75) {
        riskColor = Colors.deepOrange;
      } else {
        riskColor = Colors.redAccent;
      }
    });
  }

  Expanded iconCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: HomePageReusableCard(
        color: Colors.white,
        cardContent: HomePageIconContent(label, value, icon, color),
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

  getRandomEyeScanImage() {
    final random = Random();
    return eyeScanBgImage[random.nextInt(eyeScanBgImage.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        // if there are scans, but not fetched yet, display a spinner
        child: (haveScans && eyeScans.length == 0) || riskValue == ""
            ? Align(
                child: CircularProgressIndicator(),
                alignment: Alignment.center,
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircularPercentIndicator(
                            radius: 180.0,
                            lineWidth: 15.0,
                            percent: double.parse(riskValue) / 100,
                            center: Text(
                              riskValue + "%",
                              style: kTextStyle.copyWith(
                                fontSize: 30.0,
                                color: riskColor,
                              ),
                            ),
                            progressColor: riskColor,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  riskValue + "%",
                                  style: kTextStyle.copyWith(
                                      fontSize: 40, color: riskColor),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Text(
                                    riskDescription,
                                    style: kTextStyle.copyWith(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: <Widget>[
                        gender == "Male"
                            ? iconCard(FontAwesomeIcons.mars, "GENDER",
                                gender.toString(), Colors.blue)
                            : iconCard(FontAwesomeIcons.venus, "GENDER",
                                gender.toString(), Colors.pink),
                        iconCard(FontAwesomeIcons.eye, "TYPE", dm.toString(),
                            Colors.purple),
                        iconCard(FontAwesomeIcons.calendar, "DURATION",
                            duration, Colors.grey),
                        smoker == "No"
                            ? iconCard(FontAwesomeIcons.smokingBan, "SMOKER?",
                                smoker.toString(), Colors.red)
                            : iconCard(FontAwesomeIcons.smoking, "SMOKER?",
                                smoker.toString(), Colors.brown),
                      ],
                    ),
                    Row(
                      children: [
                        _commonHorizontalCard(
                            title: 'BMI', unit: 'kg/m2', val: bmi),
                        _commonHorizontalCard(
                            title: 'A1C', unit: 'mmol/mol', val: a1c),
                      ],
                    ),
                    Row(
                      children: [
                        _commonHorizontalCard(
                            title: 'SYSTOLIC', unit: 'mg/dL', val: systolic),
                        _commonHorizontalCard(
                            title: 'DIASTOLIC', unit: 'mg/dL', val: diastolic),
                      ],
                    ),
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
                                    color: Color(0xff62B47F), fontSize: 25),
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
                              height: 100.0,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15.0),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        height: 100,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              height: 100,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: FittedBox(
                                                  child: Image.asset(
                                                    getRandomEyeScanImage(),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.7,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      DateFormat.yMMMd()
                                                          .add_jm()
                                                          .format(eyeScans[
                                                                      index]
                                                                  ['timestamp']
                                                              .toDate())
                                                          .toString(),
                                                      style:
                                                          kTextStyle.copyWith(
                                                              fontSize: 16),
                                                    ),
                                                    Text(
                                                      "Condition: " +
                                                          eyeScans[index]
                                                                  ['result']
                                                              .toString()
                                                              .toUpperCase(),
                                                      style:
                                                          kTextStyle.copyWith(
                                                              fontSize: 16.0),
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
            style: kTextStyle.copyWith(color: Colors.greenAccent, fontSize: 25),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            val.toString(),
            style: kTextStyle.copyWith(fontSize: 30, color: Colors.black),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            unit,
            style: kTextStyle.copyWith(fontSize: 15),
          ),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }
}
