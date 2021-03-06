import 'dart:ui';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/custom_alert.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/screens/diagnosis_result_screen.dart';

final _firestore = FirebaseFirestore.instance;

class DiagnosisScreen extends StatefulWidget {
  static String id = "diagnosisScreen";

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var userDocument;
  var mainUserDetails;
  var currentUserDetails;
  String email;

  File imageFile;
  // for http requests
  Dio dio = new Dio();
  bool showSpinner = false;

  dynamic responseBody;
  var time;

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

  // get logged in users details
  getUserDetails() async {
    await getActualUserDocument();

    setState(() {
      currentUserDetails = userDocument.data();
      print(currentUserDetails);
    });

    setState(() {
      // shared email
      email = mainUserDetails['userEmail'];
    });
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
          reportTab: false,
        );
      },
    );
  }

  //  Open phone gallery
  _openGallery() async {
    var selectedPicture =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageFile = selectedPicture;
    });
  }

  // detect the type of DR
  _detect() async {
    if (imageFile == null) {
      createAlertDialog(
          context, "Error", "There is no image selected or captured!", 404);
    } else {
      setState(() {
        showSpinner = true;
      });
      try {
        // get the image picked
        String fileName = imageFile.path.split('/').last;

        // create FormData to be sent to the model endpoint
        FormData formData = new FormData.fromMap({
          "file":
              await MultipartFile.fromFile(imageFile.path, filename: fileName),
        });

        // Response object, formData is sent to the provided API,
        // and the result is obtained
        Response response = await dio.post(
          "https://bisfyp.azurewebsites.net/api/bisfyp",
          data: formData,
        );

        String result = response.data[0]['result'];
        String imageUrl = response.data[0]['image_url'];

        // store time of this diagnosis
        time = Timestamp.now();

        // store this diagnosis details in user eye scans collection
        // with the time of diagnosis
        if (!currentUserDetails['isFamilyMember']) {
          _firestore
              .collection("users")
              .doc(email)
              .collection("eye-scans")
              .add({
            'result': result,
            'image_url': imageUrl,
            'timestamp': time,
          });
        } else {
          // family member diagnoses
          _firestore
              .collection("users")
              .doc(email)
              .collection("family")
              .doc(mainUserDetails['currentFamilyMember'])
              .collection("eye-scans")
              .add({
            'result': result,
            'image_url': imageUrl,
            'timestamp': time,
          });
        }

        setState(() {
          showSpinner = false;
        });

        // once response is created, navigate to the result screen
        // passing the obtained details as arguments
        if (response != null) {
          var argsForResult = {
            'result': result,
            'image_url': imageUrl,
            'time': time
          };

          Navigator.pushNamed(context, DiagnosisResultScreen.id,
              arguments: argsForResult);
        } else {
          createAlertDialog(
              context, "Error", "Oops something went wrong!", 404);
        }
      } catch (e) {
        createAlertDialog(context, "Error", e.message, 404);

        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  // Open phone camera for on the spot photos
  _openCamera() async {
    var selectedPicture =
        await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = selectedPicture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: Material(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _contentText("DIABETIC RETINOPATHY", Colors.grey),
                          _contentText("Diagnosis", Colors.lightBlueAccent),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: imageFile == null
                                  // display a placeholder if no image selected
                                  ? Image.asset('images/uploadImageGrey1.png')
                                  : Image.file(
                                      imageFile,
                                      width: 500,
                                      height: 500,
                                    ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _diagnosisRaisedButton(
                                  _openCamera, Icons.camera_alt_rounded),
                              SizedBox(
                                width: 20.0,
                              ),
                              _diagnosisRaisedButton(_openGallery, Icons.photo),
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          CustomRoundedButton(
                            onPressed: () {
                              _detect();
                            },
                            colour: Color(0xff62B47F),
                            title: 'UPLOAD',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Center _contentText(String text, Color color) {
    return Center(
      child: Text(
        text,
        style: kTextStyle.copyWith(
          color: color,
          fontSize: 25,
        ),
      ),
    );
  }

  RaisedButton _diagnosisRaisedButton(Function onPress, IconData icon) {
    return RaisedButton(
      elevation: 3.0,
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      color: Colors.greenAccent,
      onPressed: onPress,
      child: Icon(
        icon,
        color: Colors.black54,
      ),
    );
  }
}
