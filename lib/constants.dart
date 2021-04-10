import 'package:flutter/material.dart';

// This constant is for the login background gradient color
const kBackgroundRedGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xff01CDFA), Color(0xffcccccc)],
);

// This constant is for the text field decoration
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
    borderSide: BorderSide(color: Color(0xff01CDFA), width: 1.0),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff01CDFA), width: 2.0),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
);

const kRegistrationFieldDecoration = InputDecoration(
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
    borderSide: BorderSide(color: Color(0xff01CDFA), width: 1.0),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff01CDFA), width: 2.0),
    borderRadius: BorderRadius.all(
      Radius.circular(32.0),
    ),
  ),
);

// This constant is for the Text style for the
const kTextStyle = TextStyle(
  color: Colors.black38,
  fontSize: 15,
  fontWeight: FontWeight.bold,
  fontFamily: 'Poppins-Regular',
);

// Registration & Edit Profile Usage
enum Gender { Male, Female }
enum DMType { Type1, Type2 }
enum Smoker { Yes, No }

Padding registrationInputLabel(String text) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      text,
      style: kTextStyle.copyWith(fontSize: 12, color: Colors.black),
    ),
  );
}

ListTile registrationRadioButton(
    String text, var value, var groupVal, Function onchange) {
  return ListTile(
    title: Text(text),
    leading: Radio(value: value, groupValue: groupVal, onChanged: onchange),
  );
}

Padding registrationTextField(
    var controller, Function onChange, String hintText, var keyboardType) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: TextField(
      controller: controller,
      onChanged: onChange,
      decoration: kRegistrationFieldDecoration.copyWith(
        hintText: hintText,
      ),
      keyboardType: keyboardType,
    ),
  );
}

//home page
const kHomePageLabelTextStyle = TextStyle(
    fontSize: 14.0,
    color: Color(0xff8d8e98),
    fontWeight: FontWeight.w400,
    fontFamily: "Poppins-SemiBold");

const kHomePageMainLabelTextStyle = TextStyle(
    fontSize: 25.0,
    color: Colors.indigo,
    fontWeight: FontWeight.w900,
    fontFamily: "Poppins-SemiBold");

const kHomePageValueTextStyle = TextStyle(
    fontSize: 18.0,
    color: Colors.black87,
    fontWeight: FontWeight.bold,
    fontFamily: "Poppins-SemiBold");

const kHomePageUnitTextStyle = TextStyle(
    fontSize: 15.0, color: Color(0xff8d8e98), fontFamily: "Poppins-SemiBold");

const kHomePageNumberTextStyle = TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.w900,
    fontFamily: "Poppins-SemiBold");

const Color kHomePageCardColor = Color(0xffffffff);
