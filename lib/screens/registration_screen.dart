import 'package:flutter/material.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class RegistrationScreen extends StatefulWidget {
  //  page routing
  static String id = "registerScreen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // registration details
  String username;
  String email;
  String bmi;
  String a1c;
  String systolic;
  String diastolic;
  String duration;
  String password;

  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  var gender;
  var smoker;
  var dm;

  bool visiblePassword = false;

  var _bmiController = TextEditingController();
  var _diastolicController = TextEditingController();
  var _a1cController = TextEditingController();
  var _systolicController = TextEditingController();
  var _durationController = TextEditingController();
  var _usernameController = TextEditingController();
  var _passwordTextFieldController = TextEditingController();
  var _emailAddressController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  // popup alert
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

  // DatePicker handler
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
          child: Container(
            decoration: BoxDecoration(
              gradient: kLoginRegistrationBackgroundGradient,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ),
              child: ListView(
                children: [
                  SizedBox(
                    height: 8.0,
                  ),
                  Hero(
                    tag: "logo",
                    child: Container(
                      height: 100,
                      child: Image.asset('images/officialLogo.png'),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 150,
                      ),
                      _commonLabelText(
                          title: "Nice to see you here 👋", fontSize: 20.0),
                    ],
                  ),
                  kTextField(_usernameController, (value) => username = value,
                      "Enter Username", TextInputType.text, true),
                  kTextField(_emailAddressController, (value) => email = value,
                      "Enter Email Address", TextInputType.emailAddress, true),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: OutlinedButton(
                      child: _commonLabelText(
                          title: "Date of Birth: $selectedDate",
                          fontSize: 14.0),
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
                  registrationRadioButton("Male", Gender.Male, gender, (value) {
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
                  kTextField(_bmiController, (value) => bmi = value,
                      "Enter BMI", TextInputType.number, true),
                  kTextField(_diastolicController, (value) => diastolic = value,
                      "Enter Diastolic Pressure", TextInputType.number, true),
                  kTextField(_a1cController, (value) => a1c = value,
                      "Enter A1C", TextInputType.number, true),
                  kTextField(_systolicController, (value) => systolic = value,
                      "Enter Systolic Pressure", TextInputType.number, true),
                  kTextField(_durationController, (value) => duration = value,
                      "Duration of Diabetes", TextInputType.number, true),
                  registrationInputLabel("Diabetes Mellitus Type"),
                  registrationRadioButton("Type 1", DMType.Type1, dm, (value) {
                    setState(() {
                      dm = value;
                    });
                  }),
                  registrationRadioButton("Type 2", DMType.Type2, dm, (value) {
                    setState(() {
                      dm = value;
                    });
                  }),
                  registrationRadioButton("No Retinopathy", DMType.None, dm,
                      (value) {
                    setState(() {
                      dm = value;
                    });
                  }),
                  registrationInputLabel("Smoker?"),
                  registrationRadioButton("Yes", Smoker.Yes, smoker, (value) {
                    setState(() {
                      smoker = value;
                    });
                  }),
                  registrationRadioButton("No", Smoker.No, smoker, (value) {
                    setState(() {
                      smoker = value;
                    });
                  }),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _passwordTextFieldController,
                      obscureText: !visiblePassword,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: "Enter Password",
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xff01CDFA),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              visiblePassword = !visiblePassword;
                            });
                          },
                          child: Icon(
                            Icons.remove_red_eye,
                            color: Color(0xff01CDFA),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: _commonLabelText(
                        title: "< - Back to Login", fontSize: 12.0),
                  ),
                  CustomRoundedButton(
                    onPressed: () async {
                      // Only allow registration if all details are filled
                      if (username == null ||
                          email == null ||
                          password == null ||
                          bmi == null ||
                          a1c == null ||
                          systolic == null ||
                          diastolic == null ||
                          duration == null ||
                          selectedDate == null ||
                          gender == null ||
                          dm == null ||
                          smoker == null ||
                          username == "" ||
                          email == "" ||
                          password == "" ||
                          bmi == "" ||
                          a1c == "" ||
                          systolic == "" ||
                          diastolic == "" ||
                          duration == "" ||
                          dm == "" ||
                          gender == "" ||
                          smoker == "") {
                        createAlertDialog(context, "Error",
                            "Please fill all the given fields to proceed", 404);
                      } else {
                        setState(() {
                          showSpinner = true;
                        });

                        try {
                          // create the user, add all details to firestore and returns a user once created
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);

                          _firestore.collection("users").doc(email).set({
                            "userEmail": email,
                            "username": username,
                            "DOB": selectedDate,
                            "BMI": bmi,
                            "A1C": a1c,
                            "systolic": systolic,
                            "diastolic": diastolic,
                            "Duration": duration,
                            "gender": gender.toString(),
                            "DM Type": dm.toString(),
                            "smoker": smoker.toString(),
                            'timestamp': Timestamp.now(),
                            "isFamilyMember": false,
                            "currentFamilyMember": ""
                          });

                          // Status based alerts - successful registration / not
                          if (newUser != null) {
                            createAlertDialog(context, "Success",
                                "Account Registered Successfully!", 200);
                          } else {
                            createAlertDialog(context, "Error",
                                "Something went wrong, try again later!", 404);
                          }

                          setState(() {
                            showSpinner = false;
                          });

                          // clear all fields
                          _emailAddressController.clear();
                          _usernameController.clear();
                          _passwordTextFieldController.clear();
                          _bmiController.clear();
                          _diastolicController.clear();
                          _systolicController.clear();
                          _durationController.clear();
                          _a1cController.clear();
                        } catch (e) {
                          createAlertDialog(context, "Error", e.message, 404);
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      }
                    },
                    colour: Color(0xff01CDFA),
                    title: 'REGISTER ACCOUNT',
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

  Text _commonLabelText({@required title, @required fontSize}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: kTextStyle.copyWith(fontSize: fontSize, color: Colors.white),
    );
  }
}
