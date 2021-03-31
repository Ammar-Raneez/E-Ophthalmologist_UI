import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/report_page_report_appointment.dart';

class ReportScreen extends StatefulWidget {
  static String id = "reportScreen";

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: ReportPageReportAppointment(hospital: "hospital", doctor: "doctor", date: "date", cardColor: Colors.orange, textColor: "0xff000000"),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  child: Text(
                    "Add Appointment",
                    style: TextStyle(
                      fontFamily: 'Poppins-SemiBold',
                    ),
                  ),
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Reports",
                  style: TextStyle(
                    color: Color(0xff8d8e98),
                    fontSize: 20,
                    fontFamily: 'Poppins-SemiBold',
                  ),
                ),
              ),
            )
          ),
          Expanded(
            child: ListView(
              children: [
                ReportPageReportAppointment(hospital: "hospital", doctor: "doctor", date: "date", cardColor: Colors.lightBlueAccent, textColor: "0xffffffff"),
                ReportPageReportAppointment(hospital: "hospital", doctor: "doctor", date: "date", cardColor: Colors.lightBlueAccent, textColor: "0xffffffff"),
                ReportPageReportAppointment(hospital: "hospital", doctor: "doctor", date: "date", cardColor: Colors.lightBlueAccent, textColor: "0xffffffff"),
                ReportPageReportAppointment(hospital: "hospital", doctor: "doctor", date: "date", cardColor: Colors.lightBlueAccent, textColor: "0xffffffff"),
                ReportPageReportAppointment(hospital: "hospital", doctor: "doctor", date: "date", cardColor: Colors.lightBlueAccent, textColor: "0xffffffff"),
                ReportPageReportAppointment(hospital: "hospital", doctor: "doctor", date: "date", cardColor: Colors.lightBlueAccent, textColor: "0xffffffff")
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: Text(
          "+",
          style: TextStyle(
            fontSize: 40
          ),
        ),
      ),
    );
  }
}
