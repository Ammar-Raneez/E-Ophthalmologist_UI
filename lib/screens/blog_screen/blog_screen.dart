import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ui/components/blog_page_article.dart';
import 'package:ui/screens/blog_screen/specific_blog_screen.dart';

class BlogScreen extends StatefulWidget {
  static String id = "blogScreen";

  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  @override
  void initState() {
    super.initState();
  }

  // all card titles
  var cardTitles = [
    "Diabetes Care",
    "Diabetes Retinopathy",
    "Eye Care",
    "Treatments"
  ];

  // some normal card bg images
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ListView.builder(
                    itemCount: cardTitles.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        var args = {"type": cardTitles[index]};
                        Navigator.pushNamed(context, SpecificBlogScreen.id,
                            arguments: args);
                      },
                      child: BlogArticle(
                        cardTitle: cardTitles[index],
                        cardColor: Colors.white54,
                        textColor: "0xFFFFFFFF",
                        bgImage: getRandomBlogImage(),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
