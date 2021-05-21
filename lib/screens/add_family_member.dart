import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

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
  var diagnosis;
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
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Text(
            "E-Ophthalmologist",
            style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
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
                  kEditProfileInputLabel("Username"),
                  kTextField(_usernameController, (value) => username = value,
                      "Enter Username", TextInputType.text, true),
                  kBuildDateTime(
                      context: context,
                      which: 'Date of Birth',
                      value: selectedDate,
                      press: () async {
                        await selectDate(context);
                      }),
                  kEditProfileInputLabel("Gender"),
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
                  kEditProfileInputLabel("BMI"),
                  kTextField(_bmiController, (value) => bmi = value,
                      "Enter BMI", TextInputType.number, true),
                  kRegistrationInputLabel("Diastolic Pressure"),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (value) {
                          if ((int.parse(value) > 200 ||
                              int.parse(value) < 40)) {
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
                          errorStyle: TextStyle(
                            color: Color(0xffffaa00),
                          ),
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
                            return 'Please enter a value between 0.0 and 12.0';
                          }
                          return null;
                        },
                        controller: _a1cController,
                        onChanged: (value) => a1c = value,
                        decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter Diastolic Pressure",
                          errorStyle: TextStyle(
                            color: Color(0xffffaa00),
                          ),
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
                          if ((int.parse(value) > 200 ||
                              int.parse(value) < 60)) {
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
                          hintText: "Enter Diastolic Pressure",
                          errorStyle: TextStyle(
                            color: Color(0xffffaa00),
                          ),
                        ),
                        enabled: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  kTextField(_systolicController, (value) => systolic = value,
                      "Enter Systolic Pressure", TextInputType.number, true),
                  kEditProfileInputLabel("Duration of Diabetes"),
                  kTextField(_durationController, (value) => duration = value,
                      "Duration of Diabetes", TextInputType.number, true),
                  kEditProfileInputLabel("Diabetes Mellitus Type"),
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
                  kEditProfileInputLabel("Diagnosed with Retinopathy?"),
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
                  kEditProfileInputLabel("Smoker?"),
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
                          diagnosis == null ||
                          smoker == null ||
                          username == "" ||
                          bmi == "" ||
                          a1c == "" ||
                          systolic == "" ||
                          diastolic == "" ||
                          duration == "" ||
                          dm == "" ||
                          gender == "" ||
                          diagnosis == "" ||
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
                            "Diagnosis": diagnosis.toString(),
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
