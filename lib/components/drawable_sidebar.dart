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
  var currentUserDetails;
  var userDocument;
  var mainUserDetails;

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
      username = currentUserDetails['username'];
    });
  }

  // get all family details
  getFamilyDetails() async {
    var document = await _firestore.collection("users").doc(user.email).get();

    var tempIds = [];
    var tempMembers = [];
    // add the main user to the beginning
    tempIds.add("");
    tempMembers.add(document.data());

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
                        if (!currentUserDetails['isFamilyMember']) {
                          _firestore.collection("users").doc(email).set({
                            "userEmail": email,
                            "username": currentUserDetails['username'],
                            "DOB": currentUserDetails['DOB'],
                            "BMI": currentUserDetails['BMI'],
                            "A1C": currentUserDetails['A1C'],
                            "systolic": currentUserDetails['systolic'],
                            "diastolic": currentUserDetails['diastolic'],
                            "Duration": currentUserDetails['Duration'],
                            "gender": currentUserDetails['gender'].toString(),
                            "DM Type": currentUserDetails['DM Type'].toString(),
                            "smoker": currentUserDetails['smoker'].toString(),
                            'timestamp': Timestamp.now(),
                            "isFamilyMember": false,
                            "currentFamilyMember": ""
                          });
                        } else {
                          _firestore
                              .collection("users")
                              .doc(email)
                              .collection("family")
                              .doc(mainUserDetails['currentFamilyMember'])
                              .set({
                            "userEmail": email,
                            "username": currentUserDetails['username'],
                            "DOB": currentUserDetails['DOB'],
                            "BMI": currentUserDetails['BMI'],
                            "A1C": currentUserDetails['A1C'],
                            "systolic": currentUserDetails['systolic'],
                            "diastolic": currentUserDetails['diastolic'],
                            "Duration": currentUserDetails['Duration'],
                            "gender": currentUserDetails['gender'].toString(),
                            "DM Type": currentUserDetails['DM Type'].toString(),
                            "smoker": currentUserDetails['smoker'].toString(),
                            'timestamp': Timestamp.now(),
                            "isFamilyMember": true,
                            "currentFamilyMember": familyIds[index]
                          });
                        }
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
