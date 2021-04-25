import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:ui/screens/reports_and_appointment/models/appointments.dart';

final _firestore = FirebaseFirestore.instance;

class AddAppointmentScreen extends StatefulWidget {
  static String id = "addAppointmentScreen";

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  User user = FirebaseAuth.instance.currentUser;
  // variables explained in sidebar
  var userDocument;
  var mainUserDetails;
  var currentUserDetails;
  String email;

  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  String selectedTime =
      TimeOfDay.now().hour.toString() + ":" + TimeOfDay.now().minute.toString();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  bool showSpinner = false;

  // appointmentID - timestamp of creation
  String appointmentID = new Timestamp.now().toString();

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

  // get current logged in user details, if family member, get theirs
  getUserDetails() async {
    await getActualUserDocument();

    setState(() {
      currentUserDetails = userDocument.data();
      print(currentUserDetails);
    });

    setState(() {
      // common email for any family member
      email = mainUserDetails['userEmail'];
    });
  }

  selectTime(BuildContext context) async {
    TimeOfDay picked =
        await showTimePicker(context: context, initialTime: startTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked.hour.toString() + ":" + picked.minute.toString();
      });
    }
  }

  //  DatePicker handler
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
        // string formatted date
        selectedDate = DateFormat("yyyy-MM-dd").format(picked);
      });

      // add an event to systems default calendar
      final Event event = Event(
        title: 'E-Ophthalmologist Appointment',
        description: 'Scheduled an appointment with $doctor',
        location: '$hospital',
        startDate: picked,
        endDate: DateTime(picked.year, picked.month, picked.day + 1),
      );
      Add2Calendar.addEvent2Cal(event);
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _commonLabelText(title: "Add Appointment", fontSize: 20.0),
                _commonLabelText(title: "Make an Appointment", fontSize: 16.0),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    itemCount: Appointment.allDetails.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) =>
                        kBuildHospitalLink(
                            doctor: Appointment.allDetails[index]['doctor'],
                            hospitals: Appointment.allDetails[index]
                                ['hospitals'],
                            telNums:
                                Appointment.allDetails[index]['telNums'] != null
                                    ? Appointment.allDetails[index]['telNums']
                                    : [null],
                            url: Appointment.allDetails[index]['channeling']),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                _commonLabelText(title: "Register Details", fontSize: 16.0),
                kRegistrationInputLabel("Hospital"),
                kTextField(
                    _hospitalController,
                    (value) => hospital = value,
                    "Please enter the fullname of the hospital",
                    TextInputType.text,
                    true),
                SizedBox(
                  height: 20,
                ),
                kRegistrationInputLabel("Doctor"),
                kTextField(_doctorController, (value) => doctor = value,
                    "Doctor", TextInputType.text, true),
                SizedBox(
                  height: 30,
                ),
                kBuildDateTime(
                    context: context,
                    which: 'Date',
                    value: selectedDate,
                    press: () async {
                      await selectDate(context);
                    }),
                SizedBox(
                  height: 20,
                ),
                kBuildDateTime(
                    context: context,
                    which: 'Time',
                    value: selectedTime,
                    press: () async {
                      await selectTime(context);
                    }),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: CustomRoundedButton(
                    onPressed: () async {
                      // only allow if all fields are not empty
                      if (doctor == null ||
                          hospital == null ||
                          selectedDate == null ||
                          selectedTime == null ||
                          doctor == "" ||
                          hospital == "" ||
                          selectedDate == "" ||
                          selectedTime == "") {
                        createAlertDialog(context, "Error",
                            "Please fill all the given fields to proceed", 404);
                      } else {
                        setState(() {
                          showSpinner = true;
                        });

                        try {
                          // add the new appointment details into the same users appointment collection
                          if (!currentUserDetails['isFamilyMember']) {
                            await _firestore
                                .collection("users")
                                .doc(email)
                                .collection("appointments")
                                .doc(appointmentID)
                                .set({
                              'doctor': doctor,
                              'hospital': hospital,
                              'date': selectedDate,
                              'time': selectedTime
                            });
                          } else {
                            // family member details
                            await _firestore
                                .collection("users")
                                .doc(email)
                                .collection("family")
                                .doc(mainUserDetails['currentFamilyMember'])
                                .collection("appointments")
                                .doc(appointmentID)
                                .set({
                              'doctor': doctor,
                              'hospital': hospital,
                              'date': selectedDate,
                              'time': selectedTime
                            });
                          }

                          createAlertDialog(context, "Success",
                              "Appointment Confirmed!", 200);

                          setState(() {
                            showSpinner = false;
                          });

                          _hospitalController.clear();
                          _doctorController.clear();
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
                )
              ],
            ),
          ),
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
