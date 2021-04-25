import 'package:flutter/material.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:ui/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static String id = "loginScreen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;

  bool visiblePassword = false;
  bool showSpinner = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var _emailAddressTextFieldController = TextEditingController();
  var _passwordTextFieldController = TextEditingController();

  // user login
  loginUserByEmailAndPassword(BuildContext context) async {
    // All fields must be provided to login
    if (email == null || email == "" || password == null || password == "") {
      createAlertDialog(
          context, "Error", "Please fill all the given fields to proceed", 404);
    } else {
      setState(() {
        showSpinner = true;
      });

      // Login by firebase signInWithEmailAndPassword
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        if (user != null) {
          setState(() {
            email = "";
            password = "";
          });
          createAlertDialog(context, "Success", "Successfully logged in!", 200);
        } else {
          createAlertDialog(
              context, "Error", "Something went wrong, try again later!", 404);
        }

        setState(() {
          showSpinner = false;
        });
      } catch (e) {
        createAlertDialog(context, "Error", e.message, 404);
        setState(() {
          showSpinner = false;
        });
      }
    }
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
          reportTab: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double keyboardOpenVisibility = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 8.0,
                    ),
                    Flexible(
                      child: Hero(
                        tag: "logo",
                        child: Container(
                          height: 100,
                          child: Image.asset('images/officialLogo.png'),
                        ),
                      ),
                    ),
                    if (keyboardOpenVisibility == 0.0)
                      Flexible(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 100,
                            ),
                            _commonLabelText(title: "Welcome!", fontSize: 20.0, color: Colors.white),
                          ],
                        ),
                      ),
                    if (keyboardOpenVisibility == 0.0)
                      _commonLabelText(
                          title: "Log in to your existing account!",
                          fontSize: 15.0, color: Colors.white),
                    TextField(
                      controller: _emailAddressTextFieldController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: "Enter your email",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _passwordTextFieldController,
                      obscureText: !visiblePassword,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: "Enter your password",
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
                    CustomRoundedButton(
                      onPressed: () {
                        loginUserByEmailAndPassword(context);

                        //  Clear inputs
                        _emailAddressTextFieldController.clear();
                        _passwordTextFieldController.clear();
                      },
                      colour: Colors.greenAccent,
                      title: 'LOG IN',
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _commonLabelText(
                              title: "Don't have an account?", fontSize: 13.0, color: Colors.black),
                          SizedBox(
                            width: 5.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              // navigate to registration screen
                              print("U tapped the sign up button");
                              Navigator.pushNamed(
                                  context, RegistrationScreen.id);
                            },
                            child: _commonLabelText(
                                title: "Sign Up", fontSize: 13.0, color: Colors.green),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Text _commonLabelText({@required title, @required fontSize, @required color}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: kTextStyle.copyWith(
        fontSize: fontSize,
        color: color
      ),
    );
  }
}
