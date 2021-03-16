import 'package:flutter/material.dart';

class HomeArticle extends StatelessWidget {
  final String cardTitle;
  final Color cardColor;
  final String textColor;

  HomeArticle(
      {@required this.cardTitle,
      @required this.cardColor,
      @required this.textColor});

  @override
  Widget build(BuildContext buildContext) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          25.0,
        ),
      ),
      child: Container(
        height: 200.0,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            cardTitle,
            style: TextStyle(
              fontSize: 20.0,
              color: Color(int.parse(textColor)),
              fontFamily: 'Poppins-SemiBold',
            ),
          ),
        ),
      ),
      color: cardColor,
    ),
  );
}
