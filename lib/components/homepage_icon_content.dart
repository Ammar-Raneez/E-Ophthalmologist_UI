import 'package:flutter/material.dart';
import 'package:ui/constants.dart';

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
          color: Colors.indigo,
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(iconLabel, style: kHomePageLabelTextStyle),
        SizedBox(
          height: 15.0,
        ),
        Text(iconValue, style: kHomePageValueTextStyle),
      ],
    );
  }
}
