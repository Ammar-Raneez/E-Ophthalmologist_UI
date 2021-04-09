import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/report_page_report_appointment.dart';
import 'package:ui/screens/add_appointment_screen.dart';
import 'package:ui/screens/add_report_screen.dart';
import 'package:ui/screens/current_screen.dart';
import 'package:ui/screens/edit_appointment_screen.dart';
import 'package:ui/screens/edit_report_screen.dart';

final _firestore = FirebaseFirestore.instance;

class ReportScreen extends StatefulWidget {
  static String id = "reportScreen";

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  User user = FirebaseAuth.instance.currentUser;

  bool haveReports = true;
  var reports = [];
  var docIds = [];

  bool haveAppointment = true;
  var appointments = [];
  var appointmentIds = [];

  bool showSpinner = false;
  bool delete = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();
    var tempReports = [];
    var tempIds = [];

    await document.reference.collection("past-reports").get().then((value) => {
          value.docs.forEach((element) {
            tempIds.add(element.id);
            tempReports.add(element.data());
          })
        });

    var tempAppointments = [];
    var tempAppointmentIds = [];

    await document.reference.collection("appointments").get().then((value) => {
          value.docs.forEach((element) {
            tempAppointmentIds.add(element.id);
            tempAppointments.add(element.data());
          })
        });

    setState(() {
      haveReports = tempReports.length != 0 ? true : false;
      haveAppointment = tempAppointments.length != 0 ? true : false;
    });

    setState(() {
      reports = tempReports;
      docIds = tempIds;
      appointments = tempAppointments;
      appointmentIds = tempAppointmentIds;
    });
  }

  createConfirmationAlert(BuildContext context, String title, String message,
      int status, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(
              20.0,
            ),
          ),
          title: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Colors.grey,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notification_important,
                      color: Colors.redAccent,
                      size: 25,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Poppins-Regular',
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          elevation: 2.0,
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  right: 10.0,
                  bottom: 5.0,
                ),
                child: MaterialButton(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 30,
                  ),
                  color: Color(0xff01CDFA),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(
                      10.0,
                    ),
                  ),
                  onPressed: () async {
                    var document = await _firestore
                        .collection("users")
                        .doc(user.email)
                        .get();

                    await document.reference
                        .collection("past-reports")
                        .doc(docIds[index])
                        .delete();

                    setState(() {
                      docIds.removeAt(index);
                      reports.removeAt(index);
                    });

                    Navigator.pushNamed(
                      context,
                      CurrentScreen.id,
                    );
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  right: 10.0,
                  bottom: 5.0,
                ),
                child: MaterialButton(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 30,
                  ),
                  color: Color(0xff01CDFA),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(
                      10.0,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      delete = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: haveReports && reports.length == 0
            ? Align(
                child: CircularProgressIndicator(),
                alignment: Alignment.center,
              )
            : Column(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Appointments",
                          style: TextStyle(
                            color: Color(0xff8d8e98),
                            fontSize: 20,
                            fontFamily: 'Poppins-SemiBold',
                          ),
                        ),
                      ),
                    ),
                  ),
                  haveAppointment
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: appointments.length,
                            itemBuilder: (BuildContext context, int index) =>
                                GestureDetector(
                              child: ReportPageReportAppointment(
                                doctor: appointments[index]['doctor'],
                                hospital: appointments[index]['hospital'],
                                date: appointments[index]['date'],
                                cardColor: Color(0xffaa0000),
                                textColor: '0xffffffff',
                              ),
                              onTap: () {
                                var argsForResult = {
                                  'doctor': appointments[index]['doctor'],
                                  'hospital': appointments[index]['hospital'],
                                  'date': appointments[index]['date'],
                                  'currentAppointmentId': appointmentIds[index]
                                };
                                Navigator.pushNamed(
                                    context, EditAppointmentScreen.id,
                                    arguments: argsForResult);
                              },
//                              onLongPress: () async {
//                                createConfirmationAlert(context, "Delete Report", "Are you sure you want to delete this report?", 200, index);
//                              }
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              "There aren't any Appointments \n Click Add Appointment to Add",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Color(0xffff0000),
                                fontFamily: 'Poppins-SemiBold',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )),
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
                          onPressed: () => Navigator.pushNamed(
                              context, AddAppointmentScreen.id),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                    ),
                  ),
                  haveReports
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: reports.length,
                            itemBuilder: (BuildContext context, int index) =>
                                GestureDetector(
                                    child: ReportPageReportAppointment(
                                      doctor: reports[index]['doctor'],
                                      hospital: reports[index]['hospital'],
                                      date: reports[index]['date'],
                                      cardColor: Color(0xff01CDFA),
                                      textColor: '0xffffffff',
                                    ),
                                    onTap: () {
                                      var argsForResult = {
                                        'doctor': reports[index]['doctor'],
                                        'hospital': reports[index]['hospital'],
                                        'date': reports[index]['date'],
                                        'image_document_urls': reports[index]
                                            ['image_document_urls'],
                                        'currentReportId': docIds[index]
                                      };
                                      Navigator.pushNamed(
                                          context, EditReportScreen.id,
                                          arguments: argsForResult);
                                    },
                                    onLongPress: () async {
                                      createConfirmationAlert(
                                          context,
                                          "Delete Report",
                                          "Are you sure you want to delete this report?",
                                          200,
                                          index);
                                    }),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              "There aren't any reports \n Click + to Add",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Color(0xffff0000),
                                fontFamily: 'Poppins-SemiBold',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddReportScreen.id),
        child: Text(
          "+",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
