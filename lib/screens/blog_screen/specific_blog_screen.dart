import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui/constants.dart';
import 'package:ui/screens/blog_screen/diabetes_care.dart';
import 'package:ui/screens/blog_screen/diabetes_retinopathy.dart';
import 'package:ui/screens/blog_screen/eye_care.dart';
import 'package:ui/screens/blog_screen/treatment.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecificBlogScreen extends StatefulWidget {
  static String id = "specificBlogScreen";

  @override
  _SpecificBlogScreenState createState() => _SpecificBlogScreenState();
}

class _SpecificBlogScreenState extends State<SpecificBlogScreen> {
  String typeOfBlog;

  // blog left images
  var blogBgImages = [
    "images/appointment1.jpg",
    "images/appointment2.jpg",
    "images/appointment3.jpg",
    "images/appointment4.jpg",
    "images/appointment5.jpg",
    "images/appointment6.jpg",
    "images/appointment7.jpg",
    "images/appointment8.jpg",
    "images/appointment9.jpg",
    "images/appointment10.jpg"
  ];

  // get a random image to display as card background
  getRandomBlogImage() {
    final random = Random();
    return blogBgImages[random.nextInt(blogBgImages.length)];
  }

  var chosenBlogType = [];
  var chosenBlogShortDescriptions = [];
  var chosenBlogTitles = [];

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    setState(() {
      // based on chosen type of blog in arguments, determine articles
      typeOfBlog = arguments['type'];
      chosenBlogType = typeOfBlog == "Diabetes Care"
          ? DiabetesCare().allBlog
          : typeOfBlog == "Diabetes Retinopathy"
              ? DiabetesRetinopathy().allBlog
              : typeOfBlog == "Eye Care"
                  ? EyeCare().allBlog
                  : Treatment().allBlog;
      chosenBlogShortDescriptions = typeOfBlog == "Diabetes Care"
          ? DiabetesCare().blogShortDescriptions
          : typeOfBlog == "Diabetes Retinopathy"
              ? DiabetesRetinopathy().blogShortDescriptions
              : typeOfBlog == "Eye Care"
                  ? EyeCare().blogShortDescriptions
                  : Treatment().blogShortDescriptions;
      chosenBlogTitles = typeOfBlog == "Diabetes Care"
          ? DiabetesCare().titles
          : typeOfBlog == "Diabetes Retinopathy"
              ? DiabetesRetinopathy().titles
              : typeOfBlog == "Eye Care"
                  ? EyeCare().titles
                  : Treatment().titles;
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "E-Ophthalmologist",
            style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.add_alert,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
          backgroundColor: Color(0xff62B47F),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Container(
                child: Text(
                  typeOfBlog,
                  textAlign: TextAlign.center,
                  style: kTextStyle.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: chosenBlogShortDescriptions.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              color: Color(0xffbbbbbb).withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: Offset(0, 2),
                            ),
                          ]),
                          height: 560,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                child: FittedBox(
                                  child: Image.asset(getRandomBlogImage()),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              _commonText(
                                context,
                                chosenBlogTitles[index],
                                kTextStyle.copyWith(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              _commonText(
                                context,
                                chosenBlogShortDescriptions[index],
                                kTextStyle,
                              ),
                              SizedBox(height: 30),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: RichText(
                                    text: TextSpan(
                                        text: "READ MORE   ->",
                                        style: kTextStyle.copyWith(
                                            color: Colors.black),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launch(chosenBlogType[index]);
                                          }),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _commonText(
      BuildContext context, String text, TextStyle textStyle) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                text,
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
