import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:ui/screens/reports_and_appointment/models/appointments.dart';

final _firestore = FirebaseFirestore.instance;

class EditAppointmentScreen extends StatefulWidget {
  static String id = "editAppointmentScreen";

  @override
  _EditAppointmentScreenState createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDocument;
  var mainUserDetails;
  var currentUserDetails;
  String email;

  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  String selectedTime =
      TimeOfDay.now().hour.toString() + ":" + TimeOfDay.now().minute.toString();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  String appointmentId;
  bool showSpinner = false;

  bool enableTextFields = false;

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
          reportTab: true,
        );
      },
    );
  }

  // get the actual users document (family members document or main user)
  getActualUserDocument() async {
    var document = await _firestore.collection("users").doc(user.email).get();
    mainUserDetails = document.data();

    if (document.data()['currentFamilyMember'] == '') {
      setState(() {
        userDocument = document;
      });
    } else {
      var tempUserDocument = await _firestore
          .collection("users")
          .doc(user.email)
          .collection('family')
          .doc(mainUserDetails['currentFamilyMember'])
          .get();
      setState(() {
        userDocument = tempUserDocument;
      });
    }
  }

  // get current logged in user details
  getUserDetails() async {
    await getActualUserDocument();

    setState(() {
      currentUserDetails = userDocument.data();
      print(currentUserDetails);
    });

    setState(() {
      email = mainUserDetails['userEmail'];
    });
  }

  selectTime(BuildContext context) async {
    TimeOfDay picked =
        await showTimePicker(context: context, initialTime: startTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked.hour.toString() + ":" + picked.minute.toString();
      });
    }
  }

  // DatePicker handler
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

    // get the specific appointments details passed as arguments
    setState(() {
      doctor = arguments['doctor'];
      hospital = arguments['hospital'];
      appointmentId = arguments['currentDocId'];
    });

    setState(() {
      // populate the text field with the already set values
      _doctorController =
          TextEditingController.fromValue(TextEditingValue(text: "$doctor"));
      _hospitalController =
          TextEditingController.fromValue(TextEditingValue(text: "$hospital"));
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "E-Ophthalmologist",
            style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Color(0xff62B47F),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _commonLabelText(
                    title: enableTextFields
                        ? "Edit Appointment"
                        : "View Appointment",
                    fontSize: 20.0),
                SizedBox(
                  height: 30,
                ),
                _commonLabelText(title: "Register Details", fontSize: 16.0),
                kRegistrationInputLabel("Hospital"),
                kTextField(_hospitalController, (value) => hospital = value,
                    "Hospital", TextInputType.text, enableTextFields),
                SizedBox(
                  height: 20,
                ),
                kRegistrationInputLabel("Doctor"),
                kTextField(_doctorController, (value) => doctor = value,
                    "Doctor", TextInputType.text, enableTextFields),
                SizedBox(
                  height: 30,
                ),
                kBuildDateTime(
                    context: context,
                    which: 'Date',
                    value: selectedDate,
                    press: () async {
                      enableTextFields && await selectDate(context);
                    }),
                kBuildDateTime(
                    context: context,
                    which: 'Time',
                    value: selectedTime,
                    press: () async {
                      enableTextFields && await selectTime(context);
                    }),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: enableTextFields
                      ? CustomRoundedButton(
                          onPressed: () async {
                            if (doctor == null ||
                                hospital == null ||
                                selectedDate == null ||
                                selectedTime == null ||
                                doctor == "" ||
                                hospital == "" ||
                                selectedDate == "" ||
                                selectedTime == "") {
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
                                // update the specific appointments details
                                if (!currentUserDetails['isFamilyMember']) {
                                  // main user appointment
                                  await _firestore
                                      .collection("users")
                                      .doc(email)
                                      .collection("appointments")
                                      .doc(appointmentId)
                                      .set({
                                    'doctor': doctor,
                                    'hospital': hospital,
                                    'date': selectedDate,
                                    'time': selectedTime
                                  });
                                } else {
                                  // family member appointment
                                  await _firestore
                                      .collection("users")
                                      .doc(email)
                                      .collection("family")
                                      .doc(mainUserDetails[
                                          'currentFamilyMember'])
                                      .collection("appointments")
                                      .doc(appointmentId)
                                      .set({
                                    'doctor': doctor,
                                    'hospital': hospital,
                                    'date': selectedDate,
                                    'time': selectedTime
                                  });
                                }

                                createAlertDialog(
                                    context,
                                    "Success",
                                    "Appointment has been edited successfully!",
                                    200);

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
                          title: "CONFIRM APPOINTMENT",
                          colour: Color(0xff62B47F),
                        )
                      : CustomRoundedButton(
                          onPressed: () {
                            setState(() {
                              enableTextFields = true;
                            });
                          },
                          title: "EDIT",
                          colour: Color(0xff62B47F),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _commonLabelText({@required title, @required fontSize}) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: kTextStyle.copyWith(
            fontSize: fontSize,
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
