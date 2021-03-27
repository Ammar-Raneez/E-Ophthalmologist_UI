import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/homepage_icon_content.dart';
import 'package:ui/components/homepage_reusable_card.dart';
import 'package:ui/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      print(userDetails);
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
    });
  }

  Expanded iconCard(IconData icon, String genderText) {
    return Expanded(
      child: HomePageReusableCard(
          color: kHomePageInactiveCardColor,
          cardContent: HomePageIconContent(genderText, icon),
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
          : ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    gender == "Male" ? iconCard(FontAwesomeIcons.mars, gender.toString()) : iconCard(FontAwesomeIcons.venus, gender.toString()),
                    dm == "Type I" ? iconCard(FontAwesomeIcons.eye, dm.toString()) : iconCard(FontAwesomeIcons.eye, dm.toString()),
                    iconCard(FontAwesomeIcons.calendar, "Duration"),
                    smoker == "No" ? iconCard(FontAwesomeIcons.smokingBan, smoker.toString()) : iconCard(FontAwesomeIcons.smoking, smoker.toString()),
                  ],
                ),
                HomePageReusableCard(
                  cardContent: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'BMI',
                        style: kHomePageLabelTextStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            bmi.toString(),
                            style: kHomePageNumberTextStyle,
                          ),
                          Text(
                            'cm',
                            style: kHomePageLabelTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                HomePageReusableCard(
                  cardContent: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'A1C',
                        style: kHomePageLabelTextStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            a1c.toString(),
                            style: kHomePageNumberTextStyle,
                          ),
                          Text(
                            'cm',
                            style: kHomePageLabelTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                HomePageReusableCard(
                  cardContent: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'LDL',
                        style: kHomePageLabelTextStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            ldl.toString(),
                            style: kHomePageNumberTextStyle,
                          ),
                          Text(
                            'cm',
                            style: kHomePageLabelTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                HomePageReusableCard(
                  cardContent: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'HDL',
                        style: kHomePageLabelTextStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            hdl.toString(),
                            style: kHomePageNumberTextStyle,
                          ),
                          Text(
                            'cm',
                            style: kHomePageLabelTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
          ),
      ),
    );
  }
}
