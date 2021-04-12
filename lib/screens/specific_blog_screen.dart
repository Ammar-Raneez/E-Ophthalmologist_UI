import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecificBlogScreen extends StatefulWidget {
  static String id = "specificBlogScreen";

  @override
  _SpecificBlogScreenState createState() => _SpecificBlogScreenState();
}

class _SpecificBlogScreenState extends State<SpecificBlogScreen> {
  String typeOfBlog;

  // links to navigate for each blog
  var drStagesArticles = ["https://flutter.dev"];
  var drTypesArticles = ["https://flutter.dev"];
  var guidelinesArticles = ["https://flutter.dev"];
  var treatmentsArticles = ["https://flutter.dev"];

  //short descriptions and associated blog titles
  var drStagesShortDescriptions = [
    "adipiscing elit ut aliquam purus sit amet luctus venenatis lectus magna fringilla urna porttitor rhoncus dolor purus non enim praesent elementum facilisis leo vel fringilla est ullamcorper eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus in ornare quam viverra orci sagittis eu volutpat odio facilisis..."
  ];
  var drStagesTitles = ["How To Prevent Diabetic Retinopathy?"];
  var drTypesShortDescriptions = [
    "adipiscing elit ut aliquam purus sit amet luctus venenatis lectus magna fringilla urna porttitor rhoncus dolor purus non enim praesent elementum facilisis leo vel fringilla est ullamcorper eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus in ornare quam viverra orci sagittis eu volutpat odio facilisis..."
  ];
  var drTypesTitles = ["How To Prevent Diabetic Retinopathy?"];
  var guidelinesShortDescriptions = [
    "adipiscing elit ut aliquam purus sit amet luctus venenatis lectus magna fringilla urna porttitor rhoncus dolor purus non enim praesent elementum facilisis leo vel fringilla est ullamcorper eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus in ornare quam viverra orci sagittis eu volutpat odio facilisis..."
  ];
  var guidelinesTitles = ["How To Prevent Diabetic Retinopathy?"];
  var treatmentsShortDescriptions = [
    "adipiscing elit ut aliquam purus sit amet luctus venenatis lectus magna fringilla urna porttitor rhoncus dolor purus non enim praesent elementum facilisis leo vel fringilla est ullamcorper eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus in ornare quam viverra orci sagittis eu volutpat odio facilisis..."
  ];
  var treatmentTitles = ["How To Prevent Diabetic Retinopathy?"];

  // blog left images
  var blogImages = ["images/tempblog.jpg"];

  var chosenBlogType = [];
  var chosenBlogShortDescriptions = [];
  var chosenBlogTitles = [];

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    setState(() {
      // based on chosen type of blog in arguments, determine articles
      typeOfBlog = arguments['type'];
      chosenBlogType = typeOfBlog == "Retinopathy Stages"
          ? drStagesArticles
          : typeOfBlog == "Diabetes Types"
              ? drTypesArticles
              : typeOfBlog == "Guidelines"
                  ? guidelinesArticles
                  : treatmentsArticles;
      chosenBlogShortDescriptions = typeOfBlog == "Retinopathy Stages"
          ? drStagesShortDescriptions
          : typeOfBlog == "Diabetes Types"
              ? drTypesShortDescriptions
              : typeOfBlog == "Guidelines"
                  ? guidelinesShortDescriptions
                  : treatmentsShortDescriptions;
      chosenBlogTitles = typeOfBlog == "Retinopathy Stages"
          ? drStagesTitles
          : typeOfBlog == "Diabetes Types"
              ? drTypesTitles
              : typeOfBlog == "Guidelines"
                  ? guidelinesTitles
                  : treatmentTitles;
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
                  itemCount: 11,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 550,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.red,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                child: FittedBox(
                                  child: Image.asset(blogImages[0]),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          chosenBlogTitles[0],
                                          style: kTextStyle.copyWith(
                                            fontSize: 20.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(chosenBlogShortDescriptions[0],
                                            style: kTextStyle),
                                      ],
                                    ),
                                  ),
                                ),
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
                                            launch(chosenBlogType[0]);
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
                        height: 30,
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
}
