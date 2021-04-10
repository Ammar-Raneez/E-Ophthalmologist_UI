import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/rounded_button.dart';
import 'package:ui/constants.dart';

final _firestore = FirebaseFirestore.instance;

class AddAppointmentScreen extends StatefulWidget {
  static String id = "addAppointmentScreen";

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  User user = FirebaseAuth.instance.currentUser;

  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  var userDetails;
  String email;
  bool showSpinner = false;

  // appointmentID - timestamp of creation
  String appointmentID = new Timestamp.now().toString();

  var hospitalNames = [
    "National Eye Hospital",
    "Radiant Eye Hospital",
    "Nawaloka Hospital",
    "Asiri Hospital",
    "Hemas Hospital",
    "Ninewells Hospital",
    "Lanka Hospital"
  ];
  var hospitalLinks = [
    "https://nationaleyehospital.health.gov.lk/",
    "https://radianteye.lk/",
    "https://www.nawaloka.com/",
    "https://asirihealth.com/",
    "https://www.hemas.com/",
    "https://ninewellshospital.lk/",
    "https://www.lankahospitals.com/"
  ];

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
        );
      },
    );
  }

  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    setState(() {
      userDetails = document.data();
      print(userDetails);
    });

    setState(() {
      email = userDetails['userEmail'];
    });
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
        selectedDate = DateFormat("yyyy-MM-dd").format(picked);
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
          backgroundColor: Colors.indigo,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _commonLabelText(title: "Add Appointment", fontSize: 20.0),
                _commonLabelText(title: "Make an Appointment", fontSize: 16.0),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    itemCount: hospitalNames.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) =>
                        buildHospitalLink(
                            hospital: hospitalNames[index],
                            url: hospitalLinks[index]),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                _commonLabelText(title: "Register Details", fontSize: 16.0),
                kTextField(_hospitalController, (value) => hospital = value,
                    "Hospital", TextInputType.text),
                SizedBox(
                  height: 20,
                ),
                kTextField(_doctorController, (value) => doctor = value,
                    "Doctor", TextInputType.text),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      child: Text(
                        "Date: $selectedDate",
                        style: TextStyle(
                          color: Color(0xff000000),
                        ),
                      ),
                      onPressed: () async {
                        await selectDate(context);
                      },
                      style: ButtonStyle(
                        shadowColor: MaterialStateProperty.all<Color>(
                          Color(0xff01CDFA),
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Color(0xff01CDFA),
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Color(0xff01CDFA),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: RoundedButton(
                    onPressed: () async {
                      if (doctor == null ||
                          hospital == null ||
                          selectedDate == null ||
                          doctor == "" ||
                          hospital == "" ||
                          selectedDate == "") {
                        createAlertDialog(context, "Error",
                            "Please fill all the given fields to proceed", 404);
                      } else {
                        setState(() {
                          showSpinner = true;
                        });

                        try {
                          await _firestore
                              .collection("users")
                              .doc(email)
                              .collection("appointments")
                              .doc(appointmentID)
                              .set({
                            'doctor': doctor,
                            'hospital': hospital,
                            'date': selectedDate,
                          });

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
                    colour: Color(0xff01CDFA),
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
