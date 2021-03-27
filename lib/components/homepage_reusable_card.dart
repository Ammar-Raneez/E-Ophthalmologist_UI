import 'package:flutter/material.dart';

class HomePageReusableCard extends StatelessWidget {
  //only one assignment
  final Color color;
  final cardContent;

  HomePageReusableCard({this.color, this.cardContent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: cardContent,
        margin: EdgeInsets.all(5.0),
        height: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
