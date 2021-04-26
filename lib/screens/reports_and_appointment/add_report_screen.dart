import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ui/screens/blog_screen/specific_blog_screen.dart';

final _firestore = FirebaseFirestore.instance;

class AddReportScreen extends StatefulWidget {
  static String id = "addReportScreen";

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDocument;
  var mainUserDetails;
  var currentUserDetails;

  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  String email;
  bool showSpinner = false;

  // hold documents firebase deployed links and their respective extensions
  var allDocumentsExtensions = [];
  var allDocumentsURLS = [];

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

  // Open phone and path to the documents and deploy to firebase
  _openAndUpload() async {
    // allow only images and pdf
    var selectedDocument = await FilePicker.platform.pickFiles(
        allowedExtensions: ['jpg', 'png', 'pdf'], type: FileType.custom);
    PlatformFile platformFile = selectedDocument.files.first;
    String fileName = platformFile.path.split('/').last;

    // store the file extension
    allDocumentsExtensions.add(platformFile.extension);

    // get the corresponding file from the platform file
    File pickedFile = File(platformFile.path);

    setState(() {
      showSpinner = true;
    });

    // save picked document into firebase storage, in the report specific directory
    Reference ref = FirebaseStorage.instance
        .ref()
        // create a unique directory for a specific report
        .child(email +
            " " +
            mainUserDetails['currentFamilyMember'] +
            " " +
            reportID +
            "/")
        .child(fileName);
    UploadTask task = ref.putFile(pickedFile);

    String thisDocumentURL = "";
    task.whenComplete(() async {
      // once uploaded to firebase, get that download link and store into the document urls list
      thisDocumentURL = await ref.getDownloadURL();
      print(thisDocumentURL);
      setState(() {
        allDocumentsURLS.add(thisDocumentURL);
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
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                _commonLabelText(title: "Add Report", fontSize: 20.0),
                kEditProfileInputLabel("Hospital"),
                kTextField(_hospitalController, (value) => hospital = value,
                    "Hospital", TextInputType.text, true),
                kEditProfileInputLabel("Doctor"),
                kTextField(_doctorController, (value) => doctor = value,
                    "Doctor", TextInputType.text, true),
                kBuildDateTime(
                    context: context,
                    which: 'Date',
                    value: selectedDate,
                    press: () async {
                      await selectDate(context);
                    }),
                SizedBox(
                  height: 30,
                ),
                Column(
                  children: allDocumentsURLS.length != 0
                      // loop and display the picked images
                      ? List.generate(
                          allDocumentsURLS.length,
                          (index) => allDocumentsExtensions[index] != 'pdf'
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          SizedBox(
                                            width: width / 2,
                                            height: 200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                          ),
                                      imageUrl: allDocumentsURLS[index],
                                      width: width,
                                      height: 300),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 8),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        PDF.network(
                                          allDocumentsURLS[index],
                                          height: 200,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  SpecificBlogScreen.id,
                                                  arguments: {
                                                    'pdf':
                                                        allDocumentsURLS[index],
                                                    'isNetwork': true
                                                  });
                                            },
                                            child: Text(
                                              "Expand >>>",
                                              style: kTextStyle.copyWith(
                                                  color: Colors.black),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                        )
                      : List.generate(
                          1,
                          // if no documents are picked display a temporary placeholder
                          (index) => Image.asset(
                            "images/uploadImageGrey1.png",
                            width: width,
                            height: 300,
                          ),
                        ),
                ),
                SizedBox(
                  height: 40,
                ),
                CustomRoundedButton(
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
                        // add the new appointment details into the same users appointment collection
                        if (!currentUserDetails['isFamilyMember']) {
                          await _firestore
                              .collection("users")
                              .doc(email)
                              .collection("past-reports")
                              .doc(reportID)
                              .set({
                            'doctor': doctor,
                            'hospital': hospital,
                            'date': selectedDate,
                            'all_document_urls': allDocumentsURLS
                          });
                        } else {
                          // family member details
                          await _firestore
                              .collection("users")
                              .doc(email)
                              .collection("family")
                              .doc(mainUserDetails['currentFamilyMember'])
                              .collection("past-reports")
                              .doc(reportID)
                              .set({
                            'doctor': doctor,
                            'hospital': hospital,
                            'date': selectedDate,
                            'all_document_urls': allDocumentsURLS,
                            'all_document_extensions': allDocumentsExtensions
                          });
                        }

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
                  colour: Color(0xff62B47F),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openAndUpload(),
          child: Text(
            "+",
            style: TextStyle(fontSize: 40),
          ),
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
