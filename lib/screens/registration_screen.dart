import 'package:flutter/material.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/rounded_button.dart';
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
  //  registration details
  String username;
  String email;
  String bmi;
  String a1c;
  String ldl;
  String hdl;
  String password;

  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  var gender;
  var smoker;
  var dm;

  bool visibleFavouriteFood = false;
  bool visiblePassword = false;

  var _bmiController = TextEditingController();
  var _hdlController = TextEditingController();
  var _a1cController = TextEditingController();
  var _ldlController = TextEditingController();
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
          child: Container(
            decoration: BoxDecoration(
              gradient: kBackgroundRedGradient,
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
                      Text(
                        "Nice to see you here 👋",
                        textAlign: TextAlign.center,
                        style: kTextStyle.copyWith(
                          color: Color(0xffffffff),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  registrationTextField(
                      _usernameController,
                      (value) => username = value,
                      "Enter Username",
                      TextInputType.text),
                  registrationTextField(
                      _emailAddressController,
                      (value) => email = value,
                      "Enter Email Address",
                      TextInputType.emailAddress),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: OutlinedButton(
                      child: Text(
                        "Date of Birth: $selectedDate",
                        style: TextStyle(
                          color: Color(0xffffffff),
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
                  registrationTextField(_bmiController, (value) => bmi = value,
                      "Enter BMI", TextInputType.number),
                  registrationTextField(_hdlController, (value) => hdl = value,
                      "Enter HDL", TextInputType.number),
                  registrationTextField(_a1cController, (value) => a1c = value,
                      "Enter A1C", TextInputType.number),
                  registrationTextField(_ldlController, (value) => ldl = value,
                      "Enter LDL", TextInputType.number),
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
                      decoration: kRegistrationFieldDecoration.copyWith(
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
                    child: Text(
                      "<- Back to login",
                      textAlign: TextAlign.end,
                      style: kTextStyle.copyWith(
                          fontSize: 12, color: Colors.white),
                    ),
                  ),
                  RoundedButton(
                    onPressed: () async {
                      //  Only allow registration if all details are filled
                      if (username == null ||
                          email == null ||
                          password == null ||
                          bmi == null ||
                          a1c == null ||
                          ldl == null ||
                          hdl == null ||
                          selectedDate == null ||
                          gender == null ||
                          dm == null ||
                          smoker == null ||
                          username == "" ||
                          email == "" ||
                          password == "" ||
                          bmi == "" ||
                          a1c == "" ||
                          ldl == "" ||
                          hdl == "" ||
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
                          //  created the user, add all details to firestore and returns a user once created
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);

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

                          //  Status based alerts - successful registration / not
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

                          //  clear all fields
                          _emailAddressController.clear();
                          _usernameController.clear();
                          _passwordTextFieldController.clear();
                          _bmiController.clear();
                          _hdlController.clear();
                          _ldlController.clear();
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
}
