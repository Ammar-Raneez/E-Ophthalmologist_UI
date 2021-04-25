import 'package:flutter/material.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:ui/screens/registration_second_screen.dart';

class RegistrationFirstScreen extends StatefulWidget {
  //  page routing
  static String id = "registerFirtScreen";

  @override
  RegistrationFirstScreenState createState() => RegistrationFirstScreenState();
}

class RegistrationFirstScreenState extends State<RegistrationFirstScreen> {
  // registration details
  String username;
  String email;
  String password;

  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  bool visiblePassword = false;

  var _usernameController = TextEditingController();
  var _passwordTextFieldController = TextEditingController();
  var _emailAddressController = TextEditingController();

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
                          title: "Nice to see you here 👋",
                          fontSize: 20.0,
                          color: Colors.white),
                    ],
                  ),
                  kRegistrationInputLabel("Username"),
                  kTextField(_usernameController, (value) => username = value,
                      "Enter Username", TextInputType.text, true),
                  kRegistrationInputLabel("Email"),
                  kTextField(_emailAddressController, (value) => email = value,
                      "Enter Email Address", TextInputType.emailAddress, true),
                  kRegistrationInputLabel("Date of Birth"),
                  kBuildDateTime(
                      context: context,
                      which: 'Date of Birth',
                      value: selectedDate,
                      press: () async {
                        await selectDate(context);
                      }),
                  kRegistrationInputLabel("Password"),
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
                          color: Colors.greenAccent,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              visiblePassword = !visiblePassword;
                            });
                          },
                          child: Icon(
                            Icons.remove_red_eye,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: _commonLabelText(
                        title: "< - Back to Login",
                        fontSize: 12.0,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomRoundedButton(
                    onPressed: () async {
                      // Only allow registration if all details are filled
                      if (username == null ||
                          email == null ||
                          password == null ||
                          selectedDate == null ||
                          username == "" ||
                          email == "" ||
                          password == "") {
                        createAlertDialog(context, "Error",
                            "Please fill all the given fields to proceed", 404);
                      } else {
                        setState(() {
                          showSpinner = true;
                        });

                        var arguments = {
                          "username": username,
                          "email": email,
                          "password": password,
                          "selectedDate": selectedDate
                        };

                        try {
                          Navigator.pushNamed(
                              context, RegistrationSecondScreen.id,
                              arguments: arguments);

                          setState(() {
                            showSpinner = false;
                          });

                          // clear all fields
                          _emailAddressController.clear();
                          _usernameController.clear();
                          _passwordTextFieldController.clear();
                        } catch (e) {
                          createAlertDialog(context, "Error", e.message, 404);
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      }
                    },
                    colour: Colors.greenAccent,
                    title: 'CONTINUE',
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

  Text _commonLabelText(
      {@required title, @required fontSize, @required color}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: kTextStyle.copyWith(fontSize: fontSize, color: color),
    );
  }
}
