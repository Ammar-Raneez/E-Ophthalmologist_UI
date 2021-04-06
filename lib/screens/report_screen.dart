import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/report_page_report_appointment.dart';
import 'package:ui/screens/add_report_screen.dart';
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

  bool showSpinner = false;

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

    setState(() {
      haveReports = tempReports.length != 0 ? true : false;
    });

    setState(() {
      reports = tempReports;
      docIds = tempIds;
    });
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
                    child: ReportPageReportAppointment(
                        hospital: "hospital",
                        doctor: "doctor",
                        date: "date",
                        cardColor: Colors.orange,
                        textColor: "0xff000000"),
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
                          onPressed: () {},
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
                  )),
                  Expanded(
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
                          Navigator.pushNamed(context, EditReportScreen.id,
                              arguments: argsForResult);
                        },
                      ),
                    ),
                  ),
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
