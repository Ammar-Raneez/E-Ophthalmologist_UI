import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/report_page_report_appointment.dart';
import 'package:ui/constants.dart';
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
  var reportIds = [];

  bool haveAppointments = true;
  var appointments = [];
  var appointmentIds = [];

  bool showSpinner = false;
  bool delete = false;

  var appointmentBgImages = [
    "images/appointment1.jpg",
    "images/appointment2.jpg",
    "images/appointment3.jpg",
    "images/appointment4.jpg",
    "images/appointment5.jpg",
    "images/appointment6.jpg",
    "images/appointment7.jpg",
    "images/appointment8.jpg",
    "images/appointment9.jpg",
    "images/appointment10.jpg"
  ];

  var reportBgImages = [
    "images/appointment1.jpg",
    "images/appointment2.jpg",
    "images/appointment3.jpg",
    "images/appointment4.jpg",
    "images/appointment5.jpg",
    "images/appointment6.jpg",
    "images/appointment7.jpg",
    "images/appointment8.jpg",
    "images/appointment9.jpg",
    "images/appointment10.jpg"
  ];

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();
    var tempReports = [];
    var tempIds = [];

    await document.reference
        .collection("past-reports")
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                tempIds.add(element.id);
                tempReports.add(element.data());
              })
            });

    var tempAppointments = [];
    var tempAppointmentIds = [];

    await document.reference
        .collection("appointments")
        .orderBy('date')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                tempAppointmentIds.add(element.id);
                tempAppointments.add(element.data());
              })
            });

    setState(() {
      haveReports = tempReports.length != 0 ? true : false;
      haveAppointments = tempAppointments.length != 0 ? true : false;
    });

    setState(() {
      reports = tempReports;
      reportIds = tempIds;
      appointments = tempAppointments;
      appointmentIds = tempAppointmentIds;
    });
  }

  createDeleteConfirmationAlert(
      BuildContext context,
      String title,
      String message,
      int status,
      int index,
      String collection,
      var whichDocs,
      var whichIds) async {
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
                      style: kTextStyle.copyWith(fontSize: 19.0),
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
            style: kTextStyle,
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
                        .collection(collection)
                        .doc(whichIds[index])
                        .delete();

                    setState(() {
                      whichIds.removeAt(index);
                      whichDocs.removeAt(index);
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

  getRandomAppointmentImage() {
    final random = Random();
    return appointmentBgImages[random.nextInt(appointmentBgImages.length)];
  }

  getRandomReportImage() {
    final random = Random();
    return reportBgImages[random.nextInt(reportBgImages.length)];
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
                  _reportAppointmentLabels(title: "Appointments"),
                  haveAppointments
                      ? _listReportsAndAppointments(
                          whichDocs: appointments,
                          whichDocsIds: appointmentIds,
                          navigate: EditAppointmentScreen.id,
                          isReport: false,
                          firebaseCollection: 'appointments',
                          alertTitle: "Delete Appointment",
                          alertDesc:
                              "Are you sure you want to delete this appointment?",
                          cardColor: Color(0xffaa0000),
                        )
                      : _emptyReportAppointment(
                          emptyText:
                              "There aren't any Appointments \n Click Add Appointment to Add"),
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
                  _reportAppointmentLabels(title: "Reports"),
                  haveReports
                      ? _listReportsAndAppointments(
                          whichDocs: reports,
                          whichDocsIds: reportIds,
                          navigate: EditReportScreen.id,
                          isReport: true,
                          firebaseCollection: 'past-reports',
                          alertTitle: "Delete Report",
                          alertDesc:
                              "Are you sure you want to delete this report?",
                          cardColor: Color(0xff01CDFA),
                        )
                      : _emptyReportAppointment(
                          emptyText:
                              "There aren't any reports \n Click + to Add"),
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

  Expanded _emptyReportAppointment({@required emptyText}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            emptyText,
            style: kTextStyle.copyWith(
              fontSize: 20.0,
              color: Color(0xffff0000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Container _reportAppointmentLabels({@required title}) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            title,
            style: kTextStyle.copyWith(
              color: Color(0xff8d8e98),
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _listReportsAndAppointments(
      {@required whichDocs,
      @required whichDocsIds,
      @required navigate,
      @required isReport,
      @required firebaseCollection,
      @required alertTitle,
      @required alertDesc,
      @required cardColor}) {
    return Expanded(
      child: ListView.builder(
        itemCount: whichDocs.length,
        scrollDirection: isReport ? Axis.vertical : Axis.horizontal,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: ReportPageReportAppointment(
              doctor: whichDocs[index]['doctor'],
              hospital: whichDocs[index]['hospital'],
              date: whichDocs[index]['date'],
              cardColor: cardColor,
              textColor: '0xffffffff',
              bgImage: isReport
                  ? getRandomReportImage()
                  : getRandomAppointmentImage(),
            ),
            onTap: () {
              var argsForResult = {
                'doctor': whichDocs[index]['doctor'],
                'hospital': whichDocs[index]['hospital'],
                'date': whichDocs[index]['date'],
                'image_document_urls':
                    isReport ? whichDocs[index]['image_document_urls'] : "",
                'currentDocId': whichDocsIds[index]
              };
              Navigator.pushNamed(context, navigate, arguments: argsForResult);
            },
            onLongPress: () async {
              createDeleteConfirmationAlert(context, alertTitle, alertDesc, 200,
                  index, firebaseCollection, whichDocs, whichDocsIds);
            }),
      ),
    );
  }
}
