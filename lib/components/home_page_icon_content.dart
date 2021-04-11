import 'package:flutter/material.dart';
import 'package:ui/constants.dart';

// Home page first row of icons
class HomePageIconContent extends StatelessWidget {
  final String iconLabel;
  final String iconValue;
  final IconData icon;

  HomePageIconContent(this.iconLabel, this.iconValue, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 50.0,
          color: Color(0xff62B47F),
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
