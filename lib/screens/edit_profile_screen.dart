import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

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
        key: _scaffoldKey,
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
                        kEditProfileInputLabel("Username"),
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
                        kEditProfileInputLabel("Gender"),
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
                        kEditProfileInputLabel("BMI"),
                        kTextField(
                            _bmiController,
                            (value) => bmi = value,
                            "Enter BMI",
                            TextInputType.number,
                            enableTextFields),
                        kEditProfileInputLabel("Diastolic Pressure"),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (value) {
                                try {
                                  if ((int.parse(value) > 200 ||
                                      int.parse(value) < 40)) {
                                    return 'Please enter a value between 40 and 200';
                                  }
                                } catch (e) {}
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
                        kEditProfileInputLabel("A1C"),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey1,
                            child: TextFormField(
                              validator: (value) {
                                try {
                                  if ((double.parse(value) > 12.0 ||
                                      double.parse(value) < 0.0)) {
                                    return 'Please enter a value between 0.0 and 12.0';
                                  }
                                } catch (e) {}
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
                        kEditProfileInputLabel("Systolic Pressure"),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey2,
                            child: TextFormField(
                              validator: (value) {
                                try {
                                  if ((int.parse(value) > 200 ||
                                      int.parse(value) < 60)) {
                                    return 'Please enter a value between 60 and 200';
                                  }
                                } catch (e) {}
                                return null;
                              },
                              controller: _systolicController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) => systolic = value,
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: "Enter Systolic Pressure",
                                errorStyle: TextStyle(
                                  color: Color(0xffffaa00),
                                ),
                              ),
                              enabled: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        kEditProfileInputLabel("Duration of Diabetes"),
                        kTextField(
                            _durationController,
                            (value) => duration = value,
                            "Enter duration",
                            TextInputType.number,
                            enableTextFields),
                        kEditProfileInputLabel("Diabetes Mellitus Type"),
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
                        kEditProfileInputLabel("Diagnosed with Retinopathy?"),
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
                        kEditProfileInputLabel("Smoker?"),
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
                        if (enableTextFields)
                          CustomRoundedButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate() &&
                                  _formKey1.currentState.validate() &&
                                  _formKey2.currentState.validate()) {
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
                                    if (!currentUserDetails['isFamilyMember']) {
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
                                      print("update");
                                      print(username);
                                      print(currentUserDetails);
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
                              } else {
                                createAlertDialog(context, "Error",
                                    "Please provide valid values", 404);
                              }
                            },
                            colour: Color(0xff62B47F),
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
        floatingActionButton: enableTextFields
            ? null
            : FloatingActionButton(
                onPressed: () => {
                  setState(() {
                    enableTextFields = true;
                  })
                },
                child: Icon(Icons.edit),
                backgroundColor: Colors.redAccent,
              ),
      ),
    );
  }
}
