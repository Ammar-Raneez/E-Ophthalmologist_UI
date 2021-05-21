import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:ui/screens/registration_first_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class RegistrationSecondScreen extends StatefulWidget {
  //  page routing
  static String id = "registerSecondScreen";

  @override
  RegistrationSecondScreenState createState() =>
      RegistrationSecondScreenState();
}

class RegistrationSecondScreenState extends State<RegistrationSecondScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

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
  var diagnosis;

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
          reportTab: false,
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
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    setState(() {
      username = arguments['username'];
      email = arguments['email'];
      selectedDate = arguments['selectedDate'];
      password = arguments['password'];
    });

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
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
                      height: 200,
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
                  kRegistrationInputLabel("Gender"),
                  kRegistrationRadioButton("Male", Gender.Male, gender,
                      (value) {
                    setState(() {
                      gender = value;
                    });
                  }),
                  kRegistrationRadioButton("Female", Gender.Female, gender,
                      (value) {
                    setState(() {
                      gender = value;
                    });
                  }),
                  kRegistrationInputLabel("BMI"),
                  kTextField(_bmiController, (value) => bmi = value,
                      "Enter BMI", TextInputType.number, true),
                  kRegistrationInputLabel("Diastolic Pressure"),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (value) {
                          if ((double.parse(value) > 200 ||
                              double.parse(value) < 40)) {
                            return 'Please enter a value between 40 and 200';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: _diastolicController,
                        onChanged: (value) => diastolic = value,
                        decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter Diastolic Pressure",
                        ),
                        enabled: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  kRegistrationInputLabel("A1C"),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey1,
                      child: TextFormField(
                        validator: (value) {
                          print(value);
                          if ((double.parse(value) > 12 || double.parse(value) < 0)) {
                            return 'Please enter a value between 0 and 12';
                          }
                          return null;
                        },
                        controller: _a1cController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) => a1c = value,
                        decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter A1C",
                        ),
                        enabled: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  kRegistrationInputLabel("Systolic Pressure"),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey2,
                      child: TextFormField(
                        validator: (value) {
                          if ((double.parse(value) > 200 ||
                              double.parse(value) < 60)) {
                            return 'Please enter a value between 60 and 200';
                          }
                          return null;
                        },
                        controller: _systolicController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) => systolic = value,
                        decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter Systolic Pressure",
                        ),
                        enabled: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  kRegistrationInputLabel("Duration of Diabetes"),
                  kTextField(_durationController, (value) => duration = value,
                      "Duration of Diabetes", TextInputType.number, true),
                  kRegistrationInputLabel("Diabetes Mellitus Type"),
                  kRegistrationRadioButton("Type 1", DMType.Type1, dm, (value) {
                    setState(() {
                      dm = value;
                    });
                  }),
                  kRegistrationRadioButton("Type 2", DMType.Type2, dm, (value) {
                    setState(() {
                      dm = value;
                    });
                  }),
                  kRegistrationInputLabel("Diagnosed with Retinopathy?"),
                  kRegistrationRadioButton("No", Diagnosis.No, diagnosis,
                      (value) {
                    setState(() {
                      diagnosis = value;
                    });
                  }),
                  kRegistrationRadioButton("Yes", Diagnosis.Yes, diagnosis,
                      (value) {
                    setState(() {
                      diagnosis = value;
                    });
                  }),
                  kRegistrationInputLabel("Smoker?"),
                  kRegistrationRadioButton("Yes", Smoker.Yes, smoker, (value) {
                    setState(() {
                      smoker = value;
                    });
                  }),
                  kRegistrationRadioButton("No", Smoker.No, smoker, (value) {
                    setState(() {
                      smoker = value;
                    });
                  }),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RegistrationFirstScreen.id);
                    },
                    child: _commonLabelText(title: "< - Back", fontSize: 12.0),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomRoundedButton(
                      colour: Colors.greenAccent,
                      title: 'REGISTER ACCOUNT',
                      onPressed: () async {
                        if (_formKey.currentState.validate() &&
                            _formKey1.currentState.validate() &&
                            _formKey2.currentState.validate()) {
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
                              diagnosis == null ||
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
                              diagnosis == "" ||
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
                                "Diagnosis": diagnosis.toString(),
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
                                createAlertDialog(
                                    context,
                                    "Error",
                                    "Something went wrong, try again later!",
                                    404);
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
                              createAlertDialog(
                                  context, "Error", e.message, 404);
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          }
                        } else {
                          createAlertDialog(context, "Error",
                              "Oops something went wrong!", 404);
                        }
                      }),
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
