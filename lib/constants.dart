import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// This constant is for the login background gradient color
const kLoginRegistrationBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xff01CDFA), Color(0xffcccccc)],
);

// Common Constants
// This constant is for all the text fields decoration
const kTextFieldDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  hintText: '',
  hintStyle: TextStyle(color: Colors.grey),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightGreenAccent, width: 1.0),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightGreenAccent, width: 2.0),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
);

// This constant is for all text styles
const kTextStyle = TextStyle(
  color: Colors.black38,
  fontSize: 14,
  fontWeight: FontWeight.bold,
  fontFamily: 'Poppins-Regular',
);

// This constant is for all text fields
Padding kTextField(var controller, Function onChange, String hintText,
    var keyboardType, bool isEnabled) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: TextField(
      controller: controller,
      onChanged: onChange,
      decoration: kTextFieldDecoration.copyWith(
        hintText: hintText,
      ),
      enabled: isEnabled,
      keyboardType: keyboardType,
    ),
  );
}

// Registration & Edit Profile Specific
enum Gender { Male, Female }
enum DMType { Type1, Type2, None }
enum Smoker { Yes, No }

// Input labels in registration and edit
Padding registrationInputLabel(String text) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      text,
      style: kTextStyle.copyWith(fontSize: 12),
    ),
  );
}

// radio buttons in registration and edit
ListTile registrationRadioButton(
    String text, var value, var groupVal, Function onchange) {
  return ListTile(
    title: Text(text),
    leading: Radio(value: value, groupValue: groupVal, onChanged: onchange),
  );
}

// Appointment hospital links report page for edit and add appointments
Column buildHospitalLink({@required String hospital, @required String url}) {
  return Column(
    children: [
      RichText(
        text: TextSpan(
            text: hospital,
            style: kTextStyle.copyWith(fontSize: 18, color: Colors.green),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(url);
              }),
      ),
      SizedBox(
        height: 10,
      ),
    ],
  );
}
