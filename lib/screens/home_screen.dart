import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/homepage_article.dart';

final _firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  static String id = "homeScreen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDetails;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();
    setState(() {
      userDetails = document.data();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Container(
            child: userDetails == null
            ? Align(
                child: CircularProgressIndicator(),
                alignment: Alignment.center,
              )
            : Column(
                children: [
                  homeScreenTitles(
                      'Hello ${userDetails != null ? userDetails["username"] : ""}!',
                      29.0,
                      Color(0xff01CDFA)),
                  homeScreenTitles('Be Aware >>>', 15.0, Colors.grey),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Center(
                    child: ListView(
                      children: [
                        Container(
                            child: HomeArticle(
                          cardTitle: 'Article 1',
                          cardColor: Color(0xffeeeeee),
                          textColor: '0xFF757575',
                        )),
                        Container(
                            child: HomeArticle(
                          cardTitle: 'Article 2',
                          cardColor: Colors.lightBlueAccent,
                          textColor: '0xFFFFFFFF',
                        )),
                        Container(
                            child: HomeArticle(
                          cardTitle: 'Article 3',
                          cardColor: Color(0xffeeeeee),
                          textColor: '0xFF757575',
                        )),
                        Container(
                            child: HomeArticle(
                          cardTitle: 'Article 4',
                          cardColor: Colors.lightBlueAccent,
                          textColor: '0xFFFFFFFF',
                        )),
                      ],
                    ),
                  )),
                  SizedBox(
                    height: 21,
                  ),
                ],
              ),
      ),
    ));
  }

  Padding homeScreenTitles(String text, double fontSize, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Container(
        child: Align(
          child: Text(
            text,
            style: TextStyle(
                fontFamily: 'Poppins-SemiBold',
                fontSize: fontSize,
                color: color),
          ),
          alignment: Alignment.bottomLeft,
        ),
      ),
    );
  }
}
