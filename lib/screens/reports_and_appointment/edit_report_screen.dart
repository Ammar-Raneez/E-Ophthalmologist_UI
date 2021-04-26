import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';

final _firestore = FirebaseFirestore.instance;

class EditReportScreen extends StatefulWidget {
  static String id = "editReportScreen";

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDocument;
  var mainUserDetails;
  var currentUserDetails;
  String email;

  String viewedDate;
  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  String reportID;
  bool showSpinner = false;

  bool enableTextFields = false;

  // hold documents firebase deployed links and their respective extensions
  var allDocumentsURLS = [];
  var allDocumentsExtensions = [];

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

    // save chosen document into firebase storage, in the report specific directory
    Reference ref = FirebaseStorage.instance
        .ref()
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

  // DatePicker handler
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
    // get the arguments passed
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    setState(() {
      doctor = arguments['doctor'];
      hospital = arguments['hospital'];
      allDocumentsURLS = arguments['all_document_urls'];
      allDocumentsExtensions = arguments['all_document_extensions'];
      reportID = arguments['currentDocId'];
      viewedDate = arguments['date'];
    });

    // populate the text fields with the current values
    setState(() {
      _doctorController =
          TextEditingController.fromValue(TextEditingValue(text: "$doctor"));
      _hospitalController =
          TextEditingController.fromValue(TextEditingValue(text: "$hospital"));
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
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: doctor == ""
              ? Align(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                )
              : Container(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: [
                        _commonLabelText(
                            title: enableTextFields
                                ? "Edit Report"
                                : "View Report",
                            fontSize: 20.0),
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
                                      _hospitalController,
                                      (value) => hospital = value,
                                      "Hospital",
                                      TextInputType.text,
                                      enableTextFields),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  kValueReadMore("Hospital", Colors.black38),
                                  kValueReadMore(hospital, Colors.black),
                                ],
                              ),
                        enableTextFields
                            ? Column(
                                children: [
                                  kEditProfileInputLabel("Doctor"),
                                  kTextField(
                                      _doctorController,
                                      (value) => doctor = value,
                                      "Doctor",
                                      TextInputType.text,
                                      enableTextFields),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  kValueReadMore("Doctor", Colors.black38),
                                  kValueReadMore(doctor, Colors.black),
                                ],
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  kValueReadMore("Date", Colors.black38),
                                  kValueReadMore(viewedDate, Colors.black),
                                ],
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        // view mode
                        allDocumentsURLS.length != 0 && !enableTextFields
                            ? Column(
                                children: List.generate(
                                  allDocumentsURLS.length,
                                  (index) => allDocumentsExtensions[index] !=
                                          'pdf'
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CachedNetworkImage(
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      SizedBox(
                                                        width: width / 2,
                                                        height: 200,
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                        ),
                                                      ),
                                              imageUrl: allDocumentsURLS[index],
                                              width: width,
                                              height: 300),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            height: 400,
                                            child: PDF.network(
                                                allDocumentsURLS[index]),
                                          ),
                                        ),
                                ),
                              )
                            : Container(
                                height: !enableTextFields
                                    ? MediaQuery.of(context).size.height / 2
                                    : MediaQuery.of(context).size.height / 3,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No Associated documents have been added",
                                      style: kTextStyle.copyWith(fontSize: 30),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: 40,
                        ),
                        if (enableTextFields)
                          CustomRoundedButton(
                            onPressed: () async {
                              if (doctor == null ||
                                  hospital == null ||
                                  selectedDate == null ||
                                  doctor == "" ||
                                  hospital == "" ||
                                  selectedDate == "") {
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
                                  // update main user reports
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
                                    // update family member report
                                    await _firestore
                                        .collection("users")
                                        .doc(email)
                                        .collection("family")
                                        .doc(mainUserDetails[
                                            'currentFamilyMember'])
                                        .collection("past-reports")
                                        .doc(reportID)
                                        .set({
                                      'doctor': doctor,
                                      'hospital': hospital,
                                      'date': selectedDate,
                                      'all_document_urls': allDocumentsURLS
                                    });
                                  }

                                  createAlertDialog(
                                      context,
                                      "Success",
                                      "Report Details have been edited successfully!",
                                      200);

                                  setState(() {
                                    showSpinner = false;
                                  });

                                  _hospitalController.clear();
                                  _doctorController.clear();
                                } catch (e) {
                                  createAlertDialog(
                                      context, "Error", e.message, 404);
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
        ),
        floatingActionButton: enableTextFields
            ? FloatingActionButton(
                onPressed: () => _openAndUpload(),
                child: Text(
                  "+",
                  style: TextStyle(fontSize: 40),
                ),
                backgroundColor: Colors.redAccent,
              )
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
