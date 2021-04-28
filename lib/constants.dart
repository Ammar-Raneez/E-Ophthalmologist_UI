import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// This constant is for the login background gradient color
const kLoginRegistrationBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xff264c59), Color(0xff26aa59)],
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

// Registration, Edit Profile, add family member Specific
enum Gender { Male, Female }
enum DMType { Type1, Type2 }
enum Diagnosis { Yes, No }
enum Smoker { Yes, No }

// Input labels in edit profile and add family screens
Padding kEditProfileInputLabel(String text) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      text,
      style: kTextStyle.copyWith(fontSize: 12),
    ),
  );
}

// Input labels in edit profile and add family screens
Padding kRegistrationInputLabel(String text) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      text,
      style: kTextStyle.copyWith(fontSize: 12, color: Colors.white),
    ),
  );
}

// Input labels in view report and appointment screens
Padding kValueReadMore(String text, Color color) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      text,
      style: kTextStyle.copyWith(fontSize: 18, color: color),
    ),
  );
}

// radio buttons in registration and edit
ListTile kRegistrationRadioButton(
    String text, var value, var groupVal, Function onchange) {
  return ListTile(
    title: Text(text),
    leading: Radio(value: value, groupValue: groupVal, onChanged: onchange),
  );
}

// Appointment hospital links report page for add appointments
Column kBuildHospitalLink(
    {@required String doctor,
    @required var hospitals,
    @required var telNums,
    @required bool isRow,
    @required String url}) {
  return Column(
    children: [
      RichText(
        text: TextSpan(
            text: doctor,
            style: kTextStyle.copyWith(fontSize: 18, color: Colors.green),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(url);
              }),
      ),
      Container(
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: hospitals.length,
          itemBuilder: (BuildContext context, int index) => isRow
              ? Row(
                  children: [
                    Text(
                      hospitals[index],
                      style: kTextStyle,
                    ),
                    Text(telNums[index] != null ? telNums[index] : "",
                        style: kTextStyle)
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                )
              : Column(
                  children: [
                    Text(
                      hospitals[index],
                      style: kTextStyle,
                    ),
                    Text(telNums[index] != null ? telNums[index] : "",
                        style: kTextStyle),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
        ),
      ),
      SizedBox(
        height: isRow ? 20 : 30,
      ),
    ],
  );
}

// date and time picker constant
Padding kBuildDateTime(
    {@required BuildContext context,
    @required String which,
    @required String value,
    @required Function press}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      child: OutlinedButton(
        child: Text(
          "$which: $value",
          style: TextStyle(
            color: Color(0xff000000),
          ),
        ),
        onPressed: press,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.greenAccent,
          ),
        ),
      ),
    ),
  );
}
