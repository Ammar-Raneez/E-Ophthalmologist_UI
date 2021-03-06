import 'package:flutter/material.dart';
import 'package:ui/constants.dart';

// Blog page article cards
class BlogArticle extends StatelessWidget {
  final String cardTitle;
  final Color cardColor;
  final String textColor;
  final String bgImage;

  BlogArticle(
      {@required this.cardTitle,
      @required this.cardColor,
      @required this.textColor,
      @required this.bgImage});

  @override
  Widget build(BuildContext buildContext) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0),
            ),
          ),
          child: Container(
            height: 200.0,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                cardTitle,
                style: kTextStyle.copyWith(
                  fontSize: 20.0,
                  color: Color(
                    int.parse(textColor),
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(bgImage), fit: BoxFit.cover),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
          ),
          color: cardColor,
        ),
      );
}
