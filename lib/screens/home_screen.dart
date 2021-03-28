import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/homepage_icon_content.dart';
import 'package:ui/components/homepage_reusable_card.dart';
import 'package:ui/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

final _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
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

  var eyeScansSnapshot;
  var eyeScans = [];

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    setState(() {
      userDetails = document.data();
      eyeScansSnapshot = document.reference.collection("eye-scans");
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

      eyeScansSnapshot.get().then((value) => {
        value.docs.forEach((element) {
          eyeScans.add(element.data());
        })
      });
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
              style: kHomePageLabelTextStyle,
            ),
            Text(
              val.toString(),
              style: kHomePageNumberTextStyle,
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
        child: bmi == ""
          ? Align(
              child: CircularProgressIndicator(),
              alignment: Alignment.center,
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 70.0,),
                  CircularPercentIndicator(
                    radius: 300.0,
                    lineWidth: 50.0,
                    percent: 0.9,
                    center: Text(
                      "90%\nRisk",
                      style: TextStyle(
                        fontSize: 30.0, fontWeight: FontWeight.w700, color: Color(0xffdd0000),
                      ),
                    ),
                    arcType: ArcType.HALF,
                    progressColor: Color(0xffdd0000),
                  ),
                  Row(
                    children: <Widget>[
                      gender == "Male" ? iconCard(FontAwesomeIcons.mars, "GENDER", gender.toString()) : iconCard(FontAwesomeIcons.venus, "GENDER", gender.toString()),
                      iconCard(FontAwesomeIcons.eye, "TYPE", dm.toString()),
                      iconCard(FontAwesomeIcons.calendar, "DURATION", "6 Years"),
                      smoker == "No" ? iconCard(FontAwesomeIcons.smokingBan, "SMOKER?", smoker.toString()) : iconCard(FontAwesomeIcons.smoking, "SMOKER?", smoker.toString()),
                    ],
                  ),
                  HomePageReusableCard(
                    color: Colors.white,
                    cardContent: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'BMI',
                          style: kHomePageMainLabelTextStyle,
                        ),
                        SizedBox(height: 25.0,),
                        Text(
                          'kg/m2',
                          style: kHomePageUnitTextStyle,
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          bmi.toString(),
                          style: kHomePageNumberTextStyle,
                        ),
                      ],
                    ),
                  ),
                  HomePageReusableCard(
                    color: Colors.white,
                    cardContent: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'A1C',
                          style: kHomePageMainLabelTextStyle,
                        ),
                        SizedBox(height: 25.0,),
                        Text(
                          'mmol/mol',
                          style: kHomePageUnitTextStyle,
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          a1c.toString(),
                          style: kHomePageNumberTextStyle,
                        ),
                      ],
                    ),
                  ),
                  HomePageReusableCard(
                    color: Colors.white,
                    cardContent: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'LDL',
                          style: kHomePageMainLabelTextStyle,
                        ),
                        SizedBox(height: 25.0,),
                        Text(
                          'mg/dL',
                          style: kHomePageUnitTextStyle,
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          ldl.toString(),
                          style: kHomePageNumberTextStyle,
                        ),
                      ],
                    ),
                  ),
                  HomePageReusableCard(
                    color: Colors.white,
                    cardContent: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'HDL',
                          style: kHomePageMainLabelTextStyle,
                        ),
                        SizedBox(height: 25.0,),
                        Text(
                          'mg/dL',
                          style: kHomePageUnitTextStyle,
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          hdl.toString(),
                          style: kHomePageNumberTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Past Scans",
                      style: kHomePageUnitTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 100.0,
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 15,
                      itemBuilder: (BuildContext context, int index) => Card(
                        child: Column(
                          children: [

                          ],
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
}
