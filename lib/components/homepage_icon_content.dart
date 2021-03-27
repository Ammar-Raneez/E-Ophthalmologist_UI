import 'package:flutter/material.dart';
import 'package:ui/constants.dart';

class HomePageIconContent extends StatelessWidget {
  final String iconLabel;
  final IconData icon;

  HomePageIconContent(this.iconLabel, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 60.0,
        ),
        SizedBox(
          height: 15.0,
        ),
        Text(
          iconLabel,
          style: kHomePageLabelTextStyle
        ),
      ],
    );
  }
}