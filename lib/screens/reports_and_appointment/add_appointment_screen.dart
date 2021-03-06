import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:ui/screens/reports_and_appointment/models/appointments.dart';

final _firestore = FirebaseFirestore.instance;
final kGoogleApiKey = "AIzaSyA0JWatTBWml5K73myYhnK-IFGKMrNgIH8";

class AddAppointmentScreen extends StatefulWidget {
  static String id = "addAppointmentScreen";

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  User user = FirebaseAuth.instance.currentUser; // main admin user
  var currentUserDetails; // which user currently
  var userDocument; // current users document
  var mainUserDetails; // main user - (linked users will have this as main)
  String email; // single mail for multiple users

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

  var lat = 0.0;
  var lng = 0.0;

  // appointmentID - timestamp of creation, for a unique identifier
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

    // if the current family member is null - the current user is the admin
    if (document.data()['currentFamilyMember'] == '') {
      setState(() {
        userDocument = document;
      });
      // else it is a family member
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
                // the doctor details
                ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: Appointment.initialDisplay.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) =>
                      kBuildHospitalLink(
                          isRow: true,
                          doctor: Appointment.initialDisplay[index]['doctor'],
                          hospitals: Appointment.initialDisplay[index]
                              ['hospitals'],
                          telNums: Appointment.initialDisplay[index]
                                      ['telNums'] !=
                                  null
                              ? Appointment.initialDisplay[index]['telNums']
                              : [null],
                          url: Appointment.initialDisplay[index]
                              ['channeling']),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        scrollable: true,
                        title: Text(
                          "All Doctors",
                          style: kTextStyle.copyWith(fontSize: 20.0),
                        ),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        content: Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width / 1,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: Appointment.allDetails.length,
                            itemBuilder: (BuildContext context, int index) =>
                                kBuildHospitalLink(
                                  isRow: false,
                                    doctor: Appointment.allDetails[index]
                                        ['doctor'],
                                    hospitals: Appointment.allDetails[index]
                                        ['hospitals'],
                                    telNums: Appointment.allDetails[index]
                                                ['telNums'] !=
                                            null
                                        ? Appointment.allDetails[index]
                                            ['telNums']
                                        : [null],
                                    url: Appointment.allDetails[index]
                                        ['channeling']),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.green,
                              ),
                            ),
                            child: Text("Back"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Read More',
                    style: kTextStyle.copyWith(
                        color: Colors.black, fontSize: 16.0),
                    textAlign: TextAlign.end,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                _commonLabelText(title: "Register Details", fontSize: 16.0),
                kEditProfileInputLabel("Hospital"),
                kTextField(_hospitalController, (value) => hospital = value,
                    "hospital", TextInputType.text, true),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 30,
                    child: GestureDetector(
                      onTap: () async {
                        PickResult selectedPlace = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlacePicker(
                              apiKey: kGoogleApiKey,
                              useCurrentLocation: true,
                            ),
                          ),
                        );
                        lat = selectedPlace.geometry.location.lat;
                        lng = selectedPlace.geometry.location.lng;
                      },
                      child: Text(
                        'Add Location',
                        style: kTextStyle.copyWith(
                            color: Colors.black, fontSize: 16.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                kEditProfileInputLabel("Doctor"),
                kTextField(_doctorController, (value) => doctor = value,
                    "Doctor", TextInputType.text, true),
                SizedBox(
                  height: 10,
                ),
                kBuildDateTime(
                    context: context,
                    which: 'Date',
                    value: selectedDate,
                    press: () async {
                      await selectDate(context);
                    }),
                SizedBox(
                  height: 10,
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
                          lat == 0.0 ||
                          lng == 0.0 ||
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
                              'latitude': lat,
                              'longitude': lng,
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
                              'latitude': lat,
                              'longitude': lng,
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
