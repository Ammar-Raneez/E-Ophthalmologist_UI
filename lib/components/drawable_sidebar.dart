import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/constants.dart';
import 'package:ui/screens/add_family_member.dart';
import 'package:ui/screens/edit_profile_screen.dart';

final _firestore = FirebaseFirestore.instance;

class DrawableSidebar extends StatefulWidget {
  @override
  _DrawableSidebarState createState() => _DrawableSidebarState();
}

class _DrawableSidebarState extends State<DrawableSidebar> {
  User user = FirebaseAuth.instance.currentUser;
  var userDetails;

  String email = "";
  String username = "";

  bool haveFamily = false;
  var familyIds = [];
  var familyMembers = [];

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getFamilyDetails();
  }

  // get current logged in user details
  getUserDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    setState(() {
      userDetails = document.data();
      print(userDetails);
    });

    setState(() {
      email = userDetails['userEmail'];
      username = userDetails['username'];
    });
  }

  // get all family details
  getFamilyDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    var tempIds = [];
    var tempMembers = [];
    await document.reference.collection("family").get().then((value) => {
          haveFamily = true,
          value.docs.forEach((element) {
            tempIds.add(element.id);
            tempMembers.add(element.data());
          })
        });

    setState(() {
      familyIds = tempIds;
      familyMembers = tempMembers;
      print(familyMembers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: username != "" ? Text(username) : Text(""),
            accountEmail: email != "" ? Text(email) : Text(""),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'images/sidebarUser.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('images/sidebarBg.jpg'),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              "Edit Profile",
              style: kTextStyle,
            ),
            onTap: () => Navigator.pushNamed(context, EditProfileScreen.id),
          ),
          Divider(),
          haveFamily && familyMembers.length == 0
              ? Container(
                  height: 0,
                  width: 0,
                )
              : Container(
                  height: 50,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: familyMembers.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: Icon(Icons.person_pin),
                      title: Text(
                        familyMembers[index]['username'],
                        style: kTextStyle,
                      ),
                      onTap: () {
                        _firestore.collection("users").doc(email).set({
                        "userEmail": email,
                        "username": userDetails['username'],
                        "DOB": userDetails['DOB'],
                        "BMI": userDetails['BMI'],
                        "A1C": userDetails['A1C'],
                        "systolic": userDetails['systolic'],
                        "diastolic": userDetails['diastolic'],
                        "Duration": userDetails['Duration'],
                        "gender": userDetails['gender'].toString(),
                        "DM Type": userDetails['DM Type'].toString(),
                        "smoker": userDetails['smoker'].toString(),
                        'timestamp': Timestamp.now(),
                        "isFamilyMember": false,
                          "currentFamilyMember": familyMembers[index]
                              ['username']
                        });
                      },
                    ),
                  ),
                ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text(
              "Add Family Member",
              style: kTextStyle,
            ),
            onTap: () => Navigator.pushNamed(context, AddFamilyMemberScreen.id),
          )
        ],
      ),
    );
  }
}
