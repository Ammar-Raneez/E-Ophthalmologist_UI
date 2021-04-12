import 'package:flutter/material.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class AddFamilyMemberScreen extends StatefulWidget {
  //  page routing
  static String id = "addFamilyMemberScreen";

  @override
  _AddFamilyMemberScreenState createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  User mainUser = FirebaseAuth.instance.currentUser;
  String email = "";

  // new family member registration details
  String username;
  String bmi;
  String a1c;
  String systolic;
  String diastolic;
  String duration;

  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  var gender;
  var smoker;
  var dm;

  var _bmiController = TextEditingController();
  var _diastolicController = TextEditingController();
  var _a1cController = TextEditingController();
  var _systolicController = TextEditingController();
  var _durationController = TextEditingController();
  var _usernameController = TextEditingController();

  // family member id- timestamp of creation
  String memberID = new Timestamp.now().toString();

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getMainUserDetails();
  }

  getMainUserDetails() async {
    setState(() {
      email = mainUser.email;
    });
  }

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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              "E-Ophthalmologist",
              style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
            ),
          ),
          backgroundColor: Color(0xff62B47F),
        ),
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ),
              child: ListView(
                children: [
                  Container(
                    child: Text(
                      "Add Family Member",
                      textAlign: TextAlign.center,
                      style: kTextStyle.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  kTextField(_usernameController, (value) => username = value,
                      "Enter Username", TextInputType.text, true),
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
                          Color(0xff62B47F),
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Color(0xff62B47F),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Color(0xff62B47F),
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
                  CustomRoundedButton(
                    onPressed: () async {
                      // Only allow registration if all details are filled
                      if (username == null ||
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
                          // create the family member, wont have an email, since its shared
                          _firestore
                              .collection("users")
                              .doc(email)
                              .collection("family")
                              .doc(memberID)
                              .set({
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
                            "isFamilyMember": true
                          });

                          createAlertDialog(context, "Success",
                              "Account Added Successfully!", 200);

                          setState(() {
                            showSpinner = false;
                          });

                          // clear all fields
                          _usernameController.clear();
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
                    colour: Color(0xff62B47F),
                    title: 'Add Member',
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
