import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firestore = FirebaseFirestore.instance;

class AddReportScreen extends StatefulWidget {
  static String id = "addReportScreen";

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
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

  var imageDocuments = [];
  var imageDocumentsURLS = [];

  // reportID - timestamp of creation
  String reportID = new Timestamp.now().toString();

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

  //  Open phone gallery and store images into the arrays
  _openGalleryAndUpload() async {
    var selectedPicture =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    String fileName = selectedPicture.path.split('/').last;

    setState(() {
      imageDocuments.add(selectedPicture);
    });

    setState(() {
      showSpinner = true;
    });

    // save chosen image into firebase storage, in the report specific directory
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(email + " " + reportID + "/")
        .child(fileName);
    UploadTask task = ref.putFile(selectedPicture);

    String thisImageUrl = "";
    task.whenComplete(() async {
      thisImageUrl = await ref.getDownloadURL();
      print(thisImageUrl);
      setState(() {
        imageDocumentsURLS.add(thisImageUrl);
      });
    }).catchError((onError) {
      print(onError);
    });

    setState(() {
      showSpinner = false;
    });
  }

  //  DatePicker handler
  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime.now(),
      helpText: "Date",
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;

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
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                _commonLabelText(title: "Add Report", fontSize: 20.0),
                kTextField(_hospitalController, (value) => hospital = value,
                    "Hospital", TextInputType.text),
                kTextField(_doctorController, (value) => doctor = value,
                    "Doctor", TextInputType.text),
                Padding(
                  padding: const EdgeInsets.all(10.0),
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
                SizedBox(
                  height: 30,
                ),
                Column(
                  children: imageDocuments.length != 0
                      ? List.generate(
                          imageDocuments.length,
                          (index) => Image.file(imageDocuments[index],
                              width: width, height: 300),
                        )
                      : List.generate(
                          1,
                          (index) => Image.asset(
                            "images/uploadImageGrey1.png",
                            width: width,
                            height: 300,
                          ),
                        ),
                ),
                SizedBox(
                  height: 30,
                ),
                RoundedButton(
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
                            .collection("past-reports")
                            .doc(reportID)
                            .set({
                          'doctor': doctor,
                          'hospital': hospital,
                          'date': selectedDate,
                          'image_document_urls': imageDocumentsURLS
                        });

                        createAlertDialog(
                            context, "Success", "Report Added!", 200);

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
                  title: "CONFIRM",
                  colour: Color(0xff01CDFA),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openGalleryAndUpload(),
          child: Text(
            "+",
            style: TextStyle(fontSize: 40),
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
