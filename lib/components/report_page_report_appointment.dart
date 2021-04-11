import 'package:flutter/material.dart';
import 'package:ui/constants.dart';

// report page appointment and report cards
class ReportPageReportAppointment extends StatelessWidget {
  final String hospital;
  final String doctor;
  final String date;
  final Color cardColor;
  final String textColor;
  final String bgImage;

  ReportPageReportAppointment(
      {@required this.hospital,
      @required this.doctor,
      @required this.date,
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
            width: MediaQuery.of(buildContext).size.width / 1.08,
            child: Align(
              alignment: Alignment.center,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 60.0,
                    ),
                    _commonLabelText(title: hospital),
                    _commonLabelText(title: doctor),
                    _commonLabelText(title: date),
                  ],
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

  Text _commonLabelText({@required title}) {
    return Text(
      title,
      style: kTextStyle.copyWith(
        fontSize: 20.0,
        color: Color(
          int.parse(textColor),
        ),
      ),
    );
  }
}
