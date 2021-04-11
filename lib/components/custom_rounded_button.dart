import 'package:flutter/material.dart';

// custom rounded buttons (confirm, ok, in most screens)
class CustomRoundedButton extends StatelessWidget {
  final Color colour;
  final String title;
  final Function onPressed;

  CustomRoundedButton({this.title, this.colour, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 70.0,
      ),
      child: Material(
        elevation: 5.0,
        color: colour,
        borderRadius: BorderRadius.circular(
          30.0,
        ),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 100.0,
          height: 20.0,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
