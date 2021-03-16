import 'package:flutter/material.dart';
import 'package:ui/components/alert_widget.dart';
import 'package:ui/components/rounded_button.dart';
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

  loginUserByEmailAndPassword(BuildContext context) async {
    //  All fields must be provided to login
    if (email == null || email == "" || password == null || password == "") {
      createAlertDialog(
          context, "Error", "Please fill all the given fields to proceed", 404);
    } else {
      setState(() {
        showSpinner = true;
      });

      //  Login by firebase signInWithEmailAndPassword
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
        return AlertWidget(
          title: title,
          message: message,
          status: status,
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
                gradient: kBackgroundRedGradient,
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
                            Text(
                              "Welcome!",
                              textAlign: TextAlign.center,
                              style: kTextStyle.copyWith(
                                color: Color(0xffffffff),
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (keyboardOpenVisibility == 0.0)
                      Text(
                        "Log in to your existing account",
                        textAlign: TextAlign.center,
                        style: kTextStyle.copyWith(
                          fontSize: 15,
                        ),
                      ),
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
                          color: Color(0xff01CDFA),
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
                    RoundedButton(
                      onPressed: () {
                        loginUserByEmailAndPassword(context);

                        //  Clear inputs
                        _emailAddressTextFieldController.clear();
                        _passwordTextFieldController.clear();
                      },
                      colour: Color(0xff01CDFA),
                      title: 'LOG IN',
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: kTextStyle.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              print("U tapped the sign up button");
                              Navigator.pushNamed(
                                  context, RegistrationScreen.id);
                            },
                            child: Text(
                              "Sign Up",
                              style: kTextStyle.copyWith(
                                color: Color(0xff01CDFA),
                                fontSize: 13,
                              ),
                            ),
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
}
