import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/alert_widget.dart';
import 'package:ui/components/rounded_button.dart';
import 'package:ui/constants.dart';

final _firestore = FirebaseFirestore.instance;

class EditReportScreen extends StatefulWidget {
  static String id = "editReportScreen";

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  User user = FirebaseAuth.instance.currentUser;

  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  var userDetails;
  String email;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  createAlertDialog(
      BuildContext context, String title, String message, int status) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertWidget(
          title: title,
          message: message,
          status: status,
        );
      },
    );
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    setState(() {
      userDetails = document.data();
      print(userDetails);
    });

    setState(() {
      email = userDetails['userEmail'];
    });
  }

  //  DatePicker handler
  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime.now(),
      helpText: "Date of Birth",
    );
    if (picked != startDate && picked != null) {
      setState(() {
        startDate = picked;
        selectedDate = DateFormat("yyyy-MM-dd").format(startDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    setState(() {
      doctor = arguments['doctor'];
      hospital = arguments['hospital'];
      selectedDate = arguments['date'];
    });

    setState(() {
      _doctorController =
          TextEditingController.fromValue(TextEditingValue(text: "$doctor"));
      _hospitalController =
          TextEditingController.fromValue(TextEditingValue(text: "$hospital"));
    });

    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: doctor == ""
              ? Align(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                )
              : Container(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: [
                        Text(
                          "Edit Report",
                          textAlign: TextAlign.center,
                          style: kTextStyle.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        registrationTextField(
                            _hospitalController,
                            (value) => hospital = value,
                            "Hospital",
                            TextInputType.text),
                        registrationTextField(
                            _doctorController,
                            (value) => doctor = value,
                            "Doctor",
                            TextInputType.text),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: OutlinedButton(
                            child: Text(
                              "Date: $selectedDate",
                              style: TextStyle(
                                color: Color(0xff000000),
                              ),
                            ),
                            onPressed: () async {
                              await selectDate(context);
                            },
                            style: ButtonStyle(
                              shadowColor: MaterialStateProperty.all<Color>(
                                  Color(0xff01CDFA)),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xff01CDFA)),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  Color(0xff01CDFA)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RoundedButton(
                          onPressed: () async {
                            if (doctor == null ||
                                hospital == null ||
                                selectedDate == null ||
                                doctor == "" ||
                                hospital == "" ||
                                selectedDate == "") {
                              createAlertDialog(
                                  context,
                                  "Error",
                                  "Please fill all the given fields to proceed",
                                  404);
                            } else {
                              setState(() {
                                showSpinner = true;
                              });

                              try {
                                await _firestore
                                    .collection("users")
                                    .doc(email)
                                    .collection("past-reports")
                                    .doc(new Timestamp.now().toString())
                                    .set({
                                  'doctor': doctor,
                                  'hospital': hospital,
                                  'date': selectedDate
                                });

                                createAlertDialog(
                                    context, "Success", "Report Added!", 200);

                                setState(() {
                                  showSpinner = false;
                                });

                                _hospitalController.clear();
                                _doctorController.clear();
                              } catch (e) {
                                createAlertDialog(
                                    context, "Error", e.message, 404);
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            }
                          },
                          title: "CONFIRM",
                          colour: Color(0xff01CDFA),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
