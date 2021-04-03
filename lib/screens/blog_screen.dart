import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/blogpage_article.dart';

final _firestore = FirebaseFirestore.instance;

class BlogScreen extends StatefulWidget {
  static String id = "blogScreen";

  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
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
                  Expanded(
                      child: Center(
                    child: ListView(
                      children: [
                        Container(
                            child: BlogArticle(
                          cardTitle: 'Retinopathy Stages',
                          cardColor: Color(0xffeeeeee),
                          textColor: '0xFF757575',
                        )),
                        Container(
                            child: BlogArticle(
                          cardTitle: 'Diabetes Types',
                          cardColor: Colors.lightBlueAccent,
                          textColor: '0xFFFFFFFF',
                        )),
                        Container(
                            child: BlogArticle(
                          cardTitle: 'Guidelines',
                          cardColor: Color(0xffeeeeee),
                          textColor: '0xFF757575',
                        )),
                        Container(
                            child: BlogArticle(
                          cardTitle: 'Treatments',
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
