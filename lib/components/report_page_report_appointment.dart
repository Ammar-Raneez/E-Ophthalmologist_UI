import 'package:flutter/material.dart';

class ReportPageReportAppointment extends StatelessWidget {
  final String hospital;
  final String doctor;
  final String date;
  final Color cardColor;
  final String textColor;

  ReportPageReportAppointment(
      {@required this.hospital,
        @required this.doctor,
        @required this.date,
        @required this.cardColor,
        @required this.textColor});

  @override
  Widget build(BuildContext buildContext) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0)
        ),
      ),
      child: Container(
        height: 200.0,
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 60.0,),
                Text(
                  hospital,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color(int.parse(textColor)),
                    fontFamily: 'Poppins-SemiBold',
                  ),
                ),
                Text(
                  doctor,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color(int.parse(textColor)),
                    fontFamily: 'Poppins-SemiBold',
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color(int.parse(textColor)),
                    fontFamily: 'Poppins-SemiBold',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      color: cardColor,
    ),
  );
}
