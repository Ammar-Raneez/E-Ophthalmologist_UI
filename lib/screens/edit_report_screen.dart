import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
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

  String hospital;
  String doctor;
  DateTime startDate = DateTime.now();
  String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var _hospitalController = TextEditingController();
  var _doctorController = TextEditingController();

  String reportID;
  bool showSpinner = false;

  bool enableTextFields = false;

  var imageDocumentsURLS = [];

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

  // Open phone gallery and store images into the arrays
  _openGalleryAndUpload() async {
    var selectedPicture =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    String fileName = selectedPicture.path.split('/').last;

    setState(() {
      showSpinner = true;
    });

    // save chosen image into firebase storage, in the report specific directory
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(email + " " + mainUserDetails['currentFamilyMember'] + " " +  reportID + "/")
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
      imageDocumentsURLS = arguments['image_document_urls'];
      reportID = arguments['currentDocId'];
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
          title: Center(
            child: Text(
              "E-Ophthalmologist",
              style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
            ),
          ),
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
                        _commonLabelText(title: enableTextFields ? "Edit Report" : "View Report", fontSize: 20.0),
                        kTextField(
                            _hospitalController,
                            (value) => hospital = value,
                            "Hospital",
                            TextInputType.text,
                            enableTextFields),
                        kTextField(_doctorController, (value) => doctor = value,
                            "Doctor", TextInputType.text, enableTextFields),
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
                              enableTextFields && await selectDate(context);
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
                          children: imageDocumentsURLS.length != 0
                              ? List.generate(
                                  // display the images added initially, whilst
                                  // they download display a spinner
                                  imageDocumentsURLS.length,
                                  (index) => CachedNetworkImage(
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
                                      imageUrl: imageDocumentsURLS[index],
                                      width: width,
                                      height: 300),
                                )
                              // if no images, display a placeholder image
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
                          height: 40,
                        ),
                        enableTextFields
                            ? CustomRoundedButton(
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
                                      if (!currentUserDetails[
                                          'isFamilyMember']) {
                                        await _firestore
                                            .collection("users")
                                            .doc(email)
                                            .collection("past-reports")
                                            .doc(reportID)
                                            .set({
                                          'doctor': doctor,
                                          'hospital': hospital,
                                          'date': selectedDate,
                                          'image_document_urls':
                                              imageDocumentsURLS
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
                                          'image_document_urls':
                                              imageDocumentsURLS
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
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        floatingActionButton: enableTextFields
            ? FloatingActionButton(
                onPressed: () => _openGalleryAndUpload(),
                child: Text(
                  "+",
                  style: TextStyle(fontSize: 40),
                ),
                backgroundColor: Colors.redAccent,
              )
            : null,
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
