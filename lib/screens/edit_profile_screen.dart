import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';

final _firestore = FirebaseFirestore.instance;

class EditProfileScreen extends StatefulWidget {
  static String id = "editProfileScreen";

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDocument;
  var mainUserDetails;
  var currentUserDetails;
  String email;

  String selectedDate;
  static String username = "";
  static String bmi = "";
  static String a1c = "";
  static String systolic = "";
  static String diastolic = "";
  static String duration = "";

  DateTime startDate;

  var diagnosis;
  var gender;
  var dm;
  var smoker;
  var _bmiController;
  var _diastolicController;
  var _a1cController;
  var _systolicController;
  var _durationController;
  var _usernameController;

  bool enableTextFields = false;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
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

  // get current user details
  getUserDetails() async {
    await getActualUserDocument();

    setState(() {
      currentUserDetails = userDocument.data();
      print(currentUserDetails);
    });

    setState(() {
      email = mainUserDetails['userEmail'];
    });

    setState(() {
      username = currentUserDetails['username'];
      bmi = currentUserDetails['BMI'];
      a1c = currentUserDetails['A1C'];
      systolic = currentUserDetails['systolic'];
      diastolic = currentUserDetails['diastolic'];
      duration = currentUserDetails['Duration'];
      selectedDate = currentUserDetails['DOB'];
      diagnosis = currentUserDetails['Diagnosis'];
      dm = currentUserDetails['DM Type'];
      gender = currentUserDetails['gender'];
      email = currentUserDetails['userEmail'];

      // populate the text fields with the current values after fetching
      _bmiController =
          TextEditingController.fromValue(TextEditingValue(text: "$bmi"));
      _diastolicController =
          TextEditingController.fromValue(TextEditingValue(text: "$diastolic"));
      _a1cController =
          TextEditingController.fromValue(TextEditingValue(text: "$a1c"));
      _systolicController =
          TextEditingController.fromValue(TextEditingValue(text: "$systolic"));
      _durationController =
          TextEditingController.fromValue(TextEditingValue(text: "$duration"));
      _usernameController =
          TextEditingController.fromValue(TextEditingValue(text: "$username"));
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
                        Container(
                          child: Text(
                            enableTextFields
                                ? "Edit Your Profile"
                                : "View Your Profile",
                            textAlign: TextAlign.center,
                            style: kTextStyle.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        kRegistrationInputLabel("Username"),
                        kTextField(
                            _usernameController,
                            (value) => username = value,
                            "Enter Username",
                            TextInputType.text,
                            enableTextFields),
                        kBuildDateTime(
                            context: context,
                            which: 'Date of Birth',
                            value: selectedDate,
                            press: () async {
                              enableTextFields && await selectDate(context);
                            }),
                        kRegistrationInputLabel("Gender"),
                        kRegistrationRadioButton("Male", Gender.Male, gender,
                            (value) {
                          setState(() {
                            gender = value;
                          });
                        }),
                        kRegistrationRadioButton(
                            "Female", Gender.Female, gender, (value) {
                          setState(() {
                            gender = value;
                          });
                        }),
                        kRegistrationInputLabel("BMI"),
                        kTextField(
                            _bmiController,
                            (value) => bmi = value,
                            "Enter BMI",
                            TextInputType.number,
                            enableTextFields),
                        kRegistrationInputLabel("Diastolic Pressure"),
                        kTextField(
                            _diastolicController,
                            (value) => diastolic = value,
                            "Enter diastolic pressure",
                            TextInputType.number,
                            enableTextFields),
                        kRegistrationInputLabel("A1C"),
                        kTextField(
                            _a1cController,
                            (value) => a1c = value,
                            "Enter A1C",
                            TextInputType.number,
                            enableTextFields),
                        kRegistrationInputLabel("Systolic Pressure"),
                        kTextField(
                            _systolicController,
                            (value) => systolic = value,
                            "Enter systolic pressure",
                            TextInputType.number,
                            enableTextFields),
                        kRegistrationInputLabel("Duration of Diabetes"),
                        kTextField(
                            _durationController,
                            (value) => duration = value,
                            "Enter duration",
                            TextInputType.number,
                            enableTextFields),
                        kRegistrationInputLabel("Diabetes Mellitus Type"),
                        kRegistrationRadioButton("Type 1", DMType.Type1, dm,
                            (value) {
                          setState(() {
                            dm = value;
                          });
                        }),
                        kRegistrationRadioButton("Type 2", DMType.Type2, dm,
                            (value) {
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
                        kRegistrationRadioButton(
                            "Yes", Diagnosis.Yes, diagnosis, (value) {
                          setState(() {
                            diagnosis = value;
                          });
                        }),
                        kRegistrationInputLabel("Smoker?"),
                        kRegistrationRadioButton("Yes", Smoker.Yes, smoker,
                            (value) {
                          setState(() {
                            smoker = value;
                          });
                        }),
                        kRegistrationRadioButton("No", Smoker.No, smoker,
                            (value) {
                          setState(() {
                            smoker = value;
                          });
                        }),
                        enableTextFields
                            ? CustomRoundedButton(
                                onPressed: () async {
                                  // only allow if all details are filled
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
                                      // update main users details
                                      if (!currentUserDetails[
                                          'isFamilyMember']) {
                                        _firestore
                                            .collection("users")
                                            .doc(email)
                                            .set({
                                          "userEmail": email,
                                          "username": username,
                                          "DOB": selectedDate,
                                          "BMI": bmi,
                                          "A1C": a1c,
                                          "systolic": systolic,
                                          "diastolic": diastolic,
                                          "Duration": duration,
                                          "isFamilyMember": false,
                                          "gender": gender.toString(),
                                          "DM Type": dm.toString(),
                                          "Diagnosis": diagnosis.toString(),
                                          "smoker": smoker.toString(),
                                          'timestamp': Timestamp.now(),
                                        });
                                      } else {
                                        // update family member details
                                        _firestore
                                            .collection("users")
                                            .doc(email)
                                            .collection("family")
                                            .doc(mainUserDetails[
                                                'currentFamilyMember'])
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
                                          "isFamilyMember": true,
                                        });
                                      }

                                      createAlertDialog(context, "Success",
                                          "Details Updated Successfully!", 200);

                                      setState(() {
                                        showSpinner = false;
                                      });

                                      // clear all fields
                                      _usernameController.clear();
                                      _bmiController.clear();
                                      _diastolicController.clear();
                                      _systolicController.clear();
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
                                colour: Color(0xff62B47F),
                                title: 'CONFIRM',
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
