import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui/screens/diagnosis_screen.dart';
import 'package:ui/screens/edit_profile_screen.dart';
import 'package:ui/screens/blog_screen.dart';
import 'package:ui/screens/home_screen.dart';
import 'package:ui/screens/report_screen.dart';

class CurrentScreen extends StatefulWidget {
  static String id = "navigationBottom";

  @override
  _CurrentScreenState createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  int currentIndex = 0;
  final _auth = FirebaseAuth.instance;

  User loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //  fetch authenticated user
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        print("(Email-Password login) User is Present!");
        print(user.email);
      } else {
        print("Something");
      }
    } catch (e) {
      print(e);
    }
  }

  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          print(
              "YOU ARE QUITTING THE APPLICATION BY CLICK THE BACK ICON FROM THE PHONE DEFAULT");

          print("Signing out......");
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "E-Ophthalmologist",
              style: TextStyle(fontSize: 20.0,  fontFamily: "Poppins-SemiBold"),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.pushNamed(context, EditProfileScreen.id);
                },
              ),
            ],
            backgroundColor: Colors.indigo,
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                currentIndex = page;
              });
            },
            children: [
              HomeScreen(),
              DiagnosisScreen(),
              ReportScreen(),
              BlogScreen()
            ],
          ),
          //  Bottom Nav bar - navigate between respective pages
          bottomNavigationBar: BottomNavigationBar(
            selectedIconTheme: IconThemeData(color: Colors.indigo),
            unselectedIconTheme: IconThemeData(color: Colors.grey),
            backgroundColor: Colors.indigo,
            currentIndex: currentIndex,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            onTap: (index) {
              setState(() {
                currentIndex = index;
                _pageController.jumpToPage(
                  index,
                );
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 27,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add_a_photo,
                    size: 27,
                  ),
                  label: "Diagnose"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.attachment,
                    size: 27,
                  ),
                  label: "Reports"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add_alert,
                    size: 27,
                  ),
                  label: "Blog"),
            ],
          ),
        ),
      ),
    );
  }
}
