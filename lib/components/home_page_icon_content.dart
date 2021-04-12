import 'package:flutter/material.dart';
import 'package:ui/constants.dart';

// Home page first row of icons
class HomePageIconContent extends StatelessWidget {
  final String iconLabel;
  final String iconValue;
  final IconData icon;
  final Color iconColor;

  HomePageIconContent(
      this.iconLabel, this.iconValue, this.icon, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 50.0,
          color: iconColor,
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(iconLabel, style: kTextStyle),
        SizedBox(
          height: 15.0,
        ),
        Text(
          iconValue,
          style: kTextStyle.copyWith(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }
}
