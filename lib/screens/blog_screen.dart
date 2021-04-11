import 'package:flutter/material.dart';
import 'package:ui/components/blog_page_article.dart';
import 'package:ui/screens/specific_blog_screen.dart';

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

  var textColors = ["0xFF757575", "0xFFFFFFFF", "0xFF757575", "0xFFFFFFFF"];
  var cardColors = [
    Color(0xffeeeeee),
    Colors.lightBlueAccent,
    Color(0xffeeeeee),
    Colors.lightBlueAccent
  ];
  var cardTitles = [
    "Retinopathy Stages",
    "Diabetes Types",
    "Guidelines",
    "Treatments"
  ];

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
                        var args = {
                          "type": cardTitles[index]
                        };
                        Navigator.pushNamed(context, SpecificBlogScreen.id, arguments: args);
                      },
                      child: BlogArticle(
                          cardTitle: cardTitles[index],
                          cardColor: cardColors[index],
                          textColor: textColors[index]),
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
