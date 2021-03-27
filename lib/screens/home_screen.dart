import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/homepage_icon_content.dart';
import 'package:ui/components/homepage_reusable_card.dart';
import 'package:ui/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Gender selectedGender;
  int height = 180;
  int weight = 60;
  int age = 20;

  Expanded iconCard(Gender gender, IconData icon, String genderText) {
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
      body: ListView(
//        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              iconCard(Gender.Male, FontAwesomeIcons.mars, "Male"),
              iconCard(Gender.Male, FontAwesomeIcons.mars, "Type"),
              iconCard(Gender.Male, FontAwesomeIcons.calendar, "Duration"),
              iconCard(Gender.Male, FontAwesomeIcons.smokingBan, "Smoker"),
            ],
          ),
          HomePageReusableCard(
            cardContent: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Blood Pressure',
                  style: kHomePageLabelTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      height.toString(),
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
                  'Blood Pressure',
                  style: kHomePageLabelTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      height.toString(),
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
                  'Blood Pressure',
                  style: kHomePageLabelTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      height.toString(),
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
          Expanded(
            child: HomePageReusableCard(
              cardContent: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Blood Pressure',
                    style: kHomePageLabelTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        height.toString(),
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
          ),
        ],
      ),
    );
  }
}
