import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:url_launcher/url_launcher.dart';

final _firestore = FirebaseFirestore.instance;

class EditAppointmentScreen extends StatefulWidget {
  static String id = "editAppointmentScreen";

  @override
  _EditAppointmentScreenState createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  User user = FirebaseAuth.instance.currentUser;

  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  var userDetails;
  String email;
  String appointmentId;
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
        return CustomAlert(
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
      lastDate: DateTime(2900, 01, 01),
      helpText: "Date of Appointment",
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    setState(() {
      doctor = arguments['doctor'];
      hospital = arguments['hospital'];
      appointmentId = arguments['currentAppointmentId'];
    });

    setState(() {
      _doctorController =
          TextEditingController.fromValue(TextEditingValue(text: "$doctor"));
      _hospitalController =
          TextEditingController.fromValue(TextEditingValue(text: "$hospital"));
    });

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  "Add Appointment",
                  textAlign: TextAlign.center,
                  style: kTextStyle.copyWith(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Make an Appointment",
                  textAlign: TextAlign.center,
                  style: kTextStyle.copyWith(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 150,
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: "National Eye Hospital",
                            style: kTextStyle.copyWith(
                                fontSize: 18, color: Colors.blueAccent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch(
                                    "https://nationaleyehospital.health.gov.lk/");
                              }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Radiant Eye Hospital",
                            style: kTextStyle.copyWith(
                                fontSize: 18, color: Colors.blueAccent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch("https://radianteye.lk/");
                              }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Nawaloka Hospital",
                            style: kTextStyle.copyWith(
                                fontSize: 18, color: Colors.blueAccent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch("https://www.nawaloka.com/");
                              }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Asiri Hospital",
                            style: kTextStyle.copyWith(
                                fontSize: 18, color: Colors.blueAccent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch("https://asirihealth.com/");
                              }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Hemas Hospital",
                            style: kTextStyle.copyWith(
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch("https://www.hemas.com/");
                              }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Ninewells Hospital",
                            style: kTextStyle.copyWith(
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch("https://ninewellshospital.lk/");
                              }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Lanka Hospital",
                            style: kTextStyle.copyWith(
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch("https://www.lankahospitals.com/");
                              }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Register Details",
                  textAlign: TextAlign.center,
                  style: kTextStyle.copyWith(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                kTextField(
                    _hospitalController,
                    (value) => hospital = value,
                    "Hospital",
                    TextInputType.text),
                SizedBox(
                  height: 20,
                ),
                kTextField(_doctorController,
                    (value) => doctor = value, "Doctor", TextInputType.text),
                SizedBox(
                  height: 20,
                ),
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
                        Color(0xff01CDFA),
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color(0xff01CDFA),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(
                        Color(0xff01CDFA),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                RoundedButton(
                  onPressed: () async {
                    if (doctor == null ||
                        hospital == null ||
                        selectedDate == null ||
                        doctor == "" ||
                        hospital == "" ||
                        selectedDate == "") {
                      createAlertDialog(context, "Error",
                          "Please fill all the given fields to proceed", 404);
                    } else {
                      setState(() {
                        showSpinner = true;
                      });

                      try {
                        await _firestore
                            .collection("users")
                            .doc(email)
                            .collection("appointments")
                            .doc(appointmentId)
                            .set({
                          'doctor': doctor,
                          'hospital': hospital,
                          'date': selectedDate,
                        });

                        createAlertDialog(context, "Success",
                            "Appointment has been edited successfully!", 200);

                        setState(() {
                          showSpinner = false;
                        });

                        _hospitalController.clear();
                        _doctorController.clear();
                      } catch (e) {
                        createAlertDialog(context, "Error", e.message, 404);
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    }
                  },
                  title: "CONFIRM APPOINTMENT",
                  colour: Color(0xff01CDFA),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
