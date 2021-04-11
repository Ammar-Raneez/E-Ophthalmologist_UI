import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/constants.dart';
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

  @override
  void initState() {
    super.initState();
    getUserDetails();
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
          )
        ],
      ),
    );
  }
}
