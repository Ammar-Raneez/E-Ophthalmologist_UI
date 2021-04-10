import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/alert_widget.dart';
import 'package:ui/components/rounded_button.dart';
import 'package:ui/constants.dart';

final _firestore = FirebaseFirestore.instance;

class EditProfileScreen extends StatefulWidget {
  static String id = "editProfileScreen";

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDetails;

  String email;
  String selectedDate;

  static String username = "";
  static String bmi = "";
  static String a1c = "";
  static String ldl = "";
  static String hdl = "";

  DateTime startDate;

  var gender;
  var dm;
  var smoker;
  var _bmiController;
  var _hdlController;
  var _a1cController;
  var _ldlController;
  var _usernameController;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    setState(() {
      userDetails = document.data();
      print(userDetails);
    });

    setState(() {
      username = userDetails['username'];
      bmi = userDetails['BMI'];
      a1c = userDetails['A1C'];
      ldl = userDetails['LDL'];
      hdl = userDetails['HDL'];
      selectedDate = userDetails['DOB'];
      dm = userDetails['DM Type'];
      gender = userDetails['gender'];
      email = userDetails['userEmail'];

      _bmiController =
          TextEditingController.fromValue(TextEditingValue(text: "$bmi"));
      _hdlController =
          TextEditingController.fromValue(TextEditingValue(text: "$hdl"));
      _a1cController =
          TextEditingController.fromValue(TextEditingValue(text: "$a1c"));
      _ldlController =
          TextEditingController.fromValue(TextEditingValue(text: "$ldl"));
      _usernameController =
          TextEditingController.fromValue(TextEditingValue(text: "$username"));
    });
  }

  bool showSpinner = false;

  // popup alert
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: username == ""
              ? Align(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                )
              : Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    child: ListView(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 100,
                            ),
                            Text(
                              "Edit Your Profile",
                              textAlign: TextAlign.center,
                              style: kTextStyle.copyWith(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        registrationInputLabel("Username"),
                        registrationTextField(
                            _usernameController,
                            (value) => username = value,
                            "Enter Username",
                            TextInputType.text),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: OutlinedButton(
                            child: Text(
                              "Date of Birth: $selectedDate",
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
                        registrationInputLabel("Gender"),
                        registrationRadioButton("Male", Gender.Male, gender,
                            (value) {
                          setState(() {
                            gender = value;
                          });
                        }),
                        registrationRadioButton("Female", Gender.Female, gender,
                            (value) {
                          setState(() {
                            gender = value;
                          });
                        }),
                        registrationInputLabel("BMI"),
                        registrationTextField(
                            _bmiController,
                            (value) => bmi = value,
                            "Enter BMI",
                            TextInputType.number),
                        registrationInputLabel("HDL"),
                        registrationTextField(
                            _hdlController,
                            (value) => hdl = value,
                            "Enter HDL",
                            TextInputType.number),
                        registrationInputLabel("A1C"),
                        registrationTextField(
                            _a1cController,
                            (value) => a1c = value,
                            "Enter A1C",
                            TextInputType.number),
                        registrationInputLabel("LDL"),
                        registrationTextField(
                            _ldlController,
                            (value) => ldl = value,
                            "Enter LDL",
                            TextInputType.number),
                        registrationInputLabel("Diabetes Mellitus Type"),
                        registrationRadioButton("Type 1", DMType.Type1, dm,
                            (value) {
                          setState(() {
                            dm = value;
                          });
                        }),
                        registrationRadioButton("Type 2", DMType.Type2, dm,
                            (value) {
                          setState(() {
                            dm = value;
                          });
                        }),
                        registrationInputLabel("Smoker?"),
                        registrationRadioButton("Yes", Smoker.Yes, smoker,
                            (value) {
                          setState(() {
                            smoker = value;
                          });
                        }),
                        registrationRadioButton("No", Smoker.No, smoker,
                            (value) {
                          setState(() {
                            smoker = value;
                          });
                        }),
                        RoundedButton(
                          onPressed: () async {
                            if (username == null ||
                                bmi == null ||
                                a1c == null ||
                                ldl == null ||
                                hdl == null ||
                                selectedDate == null ||
                                gender == null ||
                                dm == null ||
                                smoker == null ||
                                username == "" ||
                                bmi == "" ||
                                a1c == "" ||
                                ldl == "" ||
                                hdl == "" ||
                                dm == "" ||
                                gender == "" ||
                                smoker == "") {
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
                                _firestore.collection("users").doc(email).set({
                                  "userEmail": email,
                                  "username": username,
                                  "DOB": selectedDate,
                                  "BMI": bmi,
                                  "A1C": a1c,
                                  "LDL": ldl,
                                  "HDL": hdl,
                                  "gender": gender.toString(),
                                  "DM Type": dm.toString(),
                                  "smoker": smoker.toString(),
                                  'timestamp': Timestamp.now(),
                                });

                                createAlertDialog(context, "Success",
                                    "Details Updated Successfully!", 200);

                                setState(() {
                                  showSpinner = false;
                                });

                                //  clear all fields
                                _usernameController.clear();
                                _bmiController.clear();
                                _hdlController.clear();
                                _ldlController.clear();
                                _a1cController.clear();
                              } catch (e) {
                                createAlertDialog(
                                    context, "Error", e.message, 404);
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            }
                          },
                          colour: Color(0xff01CDFA),
                          title: 'CONFIRM',
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
