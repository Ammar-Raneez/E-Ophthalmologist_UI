import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';

final _firestore = FirebaseFirestore.instance;

class EditAppointmentScreen extends StatefulWidget {
  static String id = "editAppointmentScreen";

  @override
  _EditAppointmentScreenState createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  User user = FirebaseAuth.instance.currentUser; // main admin user
  var currentUserDetails; // which user currently
  var userDocument; // current users document
  var mainUserDetails; // main user - (linked users will have this as main)
  String email; // single mail for multiple users

  // show date and time only in view mode, since in edit mode errors are thrown
  String viewedTime;
  String viewedDate;

  String hospitalView;
  String doctorView;
  String hospitalEdit;
  String doctorEdit;
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  String selectedTime =
      TimeOfDay.now().hour.toString() + ":" + TimeOfDay.now().minute.toString();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  // hospital marker
  Set<Marker> _markers = {};
  // hospital location
  LatLng _target;
  // get location based on address
  List<Placemark> placemark;
  Completer<GoogleMapController> _controller = Completer();

  var _hospitalControllerView = TextEditingController();
  var _hospitalControllerEdit = TextEditingController();
  var _doctorControllerView = TextEditingController();
  var _doctorControllerEdit = TextEditingController();

  // appointments unique identifier
  String appointmentId;
  bool showSpinner = false;

  // toggle edit mode
  bool enableTextFields = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
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
          reportTab: true,
        );
      },
    );
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

  // get current logged in user details
  getUserDetails() async {
    await getActualUserDocument();

    setState(() {
      currentUserDetails = userDocument.data();
      print(currentUserDetails);
    });

    setState(() {
      email = mainUserDetails['userEmail'];
    });
  }

  // time picker handler
  selectTime(BuildContext context) async {
    TimeOfDay picked =
        await showTimePicker(context: context, initialTime: startTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked.hour.toString() + ":" + picked.minute.toString();
      });
    }
  }

  // DatePicker handler
  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime(2900, 01, 01),
      helpText: "Date of Appointment",
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    // get the specific appointments details passed as arguments
    setState(() {
      doctorView = arguments['doctor'];
      hospitalView = arguments['hospital'];
      appointmentId = arguments['currentDocId'];
      viewedDate = arguments['date'];
      viewedTime = arguments['time'];
      _target = LatLng(arguments['latitude'], arguments['longitude']);
    });

    // get lat and lng of hospital
    getHospitalCoordinates() async {
      try {
        placemark = await Geolocator().placemarkFromAddress(hospitalView);
      } catch (Exception) {
        print("Location could not be found");
      }
    }

    setState(() {
      getHospitalCoordinates();
    });

    setState(() {
      // add marker at the obtained placemark lat and lng
      if (placemark != null) {
        double lat = placemark[0].position.latitude;
        double lng = placemark[0].position.longitude;
        _target = LatLng(lat, lng);
        _markers.add(Marker(
            position: _target,
            infoWindow: InfoWindow(
                title: "Appointment with, $doctorView",
                snippet: "$hospitalView"),
            markerId: MarkerId(hospitalView.toString())));
      }
    });

    setState(() {
      // populate the text field with the already set values
      _doctorControllerView = TextEditingController.fromValue(
          TextEditingValue(text: "$doctorView"));
      _hospitalControllerView = TextEditingController.fromValue(
          TextEditingValue(text: "$hospitalView"));
    });

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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _commonLabelText(
                    title: enableTextFields
                        ? "Edit Appointment"
                        : "View Appointment",
                    fontSize: 20.0),
                SizedBox(
                  height: 30,
                ),
                _commonLabelText(
                    title: enableTextFields
                        ? "Register Details"
                        : "Registered Details",
                    fontSize: 16.0),
                enableTextFields
                    ? Column(
                        children: [
                          kEditProfileInputLabel("Hospital"),
                          kTextField(
                              _hospitalControllerEdit,
                              (value) => hospitalEdit = value,
                              "Please enter the fullname of the hospital",
                              TextInputType.text,
                              enableTextFields),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          kValueReadMore("Hospital", Colors.black38),
                          kValueReadMore(hospitalView, Colors.black),
                        ],
                      ),
                SizedBox(
                  height: 20,
                ),
                enableTextFields
                    ? Column(
                        children: [
                          kEditProfileInputLabel("Doctor"),
                          kTextField(
                              _doctorControllerEdit,
                              (value) => doctorEdit = value,
                              "Doctor",
                              TextInputType.text,
                              enableTextFields),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          kValueReadMore("Doctor", Colors.black38),
                          kValueReadMore(doctorView, Colors.black),
                        ],
                      ),
                SizedBox(
                  height: 30,
                ),
                enableTextFields
                    ? kBuildDateTime(
                        context: context,
                        which: 'Date',
                        value: selectedDate,
                        press: () async {
                          enableTextFields && await selectDate(context);
                        })
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          kValueReadMore("Date", Colors.black38),
                          kValueReadMore(viewedDate, Colors.black),
                        ],
                      ),
                SizedBox(
                  height: 20,
                ),
                enableTextFields
                    ? kBuildDateTime(
                        context: context,
                        which: 'Time',
                        value: selectedTime,
                        press: () async {
                          enableTextFields && await selectTime(context);
                        })
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          kValueReadMore("Time", Colors.black38),
                          kValueReadMore(viewedDate, Colors.black),
                        ],
                      ),
                SizedBox(
                  height: 30,
                ),
                !enableTextFields && _target != null
                    // display a google map snippet of the hospital location
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _target,
                            zoom: 16.0,
                          ),
                          markers: _markers,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      )
                    // display a message if the location was not rendered
                    : Container(
                        child: Text(
                          "The specified Hospital could not be rendered, refreshing might help",
                          style: kTextStyle.copyWith(fontSize: 26),
                          textAlign: TextAlign.center,
                        ),
                      ),
                // only if edit mode
                if (enableTextFields)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: CustomRoundedButton(
                      onPressed: () async {
                        if (doctorView == null ||
                            hospitalView == null ||
                            selectedDate == null ||
                            selectedTime == null ||
                            doctorView == "" ||
                            hospitalView == "" ||
                            selectedDate == "" ||
                            selectedTime == "") {
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
                            // update the specific appointments details
                            if (!currentUserDetails['isFamilyMember']) {
                              // main user appointment
                              await _firestore
                                  .collection("users")
                                  .doc(email)
                                  .collection("appointments")
                                  .doc(appointmentId)
                                  .set({
                                'doctor': doctorEdit,
                                'hospital': hospitalEdit,
                                'date': selectedDate,
                                'time': selectedTime
                              });
                            } else {
                              // family member appointment
                              await _firestore
                                  .collection("users")
                                  .doc(email)
                                  .collection("family")
                                  .doc(mainUserDetails['currentFamilyMember'])
                                  .collection("appointments")
                                  .doc(appointmentId)
                                  .set({
                                'doctor': doctorEdit,
                                'hospital': hospitalEdit,
                                'date': selectedDate,
                                'time': selectedTime
                              });
                            }

                            createAlertDialog(
                                context,
                                "Success",
                                "Appointment has been edited successfully!",
                                200);

                            setState(() {
                              showSpinner = false;
                            });

                            _hospitalControllerView.clear();
                            _doctorControllerView.clear();
                          } catch (e) {
                            createAlertDialog(context, "Error", e.message, 404);
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        }
                      },
                      title: "CONFIRM APPOINTMENT",
                      colour: Color(0xff62B47F),
                    ),
                  ),
              ],
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

  Column _commonLabelText({@required title, @required fontSize}) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: kTextStyle.copyWith(
            fontSize: fontSize,
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
