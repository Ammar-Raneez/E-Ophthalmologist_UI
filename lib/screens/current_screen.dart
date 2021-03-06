import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/components/drawable_sidebar.dart';
import 'package:ui/constants.dart';
import 'package:ui/screens/blog_screen/all_blogs_screen.dart';
import 'package:ui/screens/diagnosis_screen.dart';
import 'package:ui/screens/home_screen.dart';
import 'package:ui/screens/reports_and_appointment/report_screen.dart';

class CurrentScreen extends StatefulWidget {
  static String id = "navigationBottom";

  @override
  _CurrentScreenState createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  int currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser;

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //  fetch authenticated user
  void getCurrentUser() async {
    try {
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
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: user.email == null
              ? Align(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                )
              : Scaffold(
                  drawer: DrawableSidebar(),
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(
                      "E-Ophthalmologist",
                      style: kTextStyle.copyWith(
                          fontSize: 20.0, color: Colors.white),
                    ),
                    actions: [
                      Builder(
                        builder: (context) => // Ensure Scaffold is in context
                            IconButton(
                                icon: Icon(Icons.menu),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer()),
                      ),
                    ],
                    backgroundColor: Color(0xff62B47F),
                  ),
                  body: PageView(
                    controller: _pageController,
                    // navigate between pages
                    onPageChanged: (page) {
                      setState(() {
                        currentIndex = page;
                      });
                    },
                    children: [
                      HomeScreen(),
                      DiagnosisScreen(),
                      ReportScreen(),
                      AllBlogsScreen()
                    ],
                  ),
                  // Bottom Nav bar - navigate between respective pages
                  bottomNavigationBar: BottomNavigationBar(
                    selectedIconTheme: IconThemeData(color: Color(0xff62B47F)),
                    unselectedIconTheme: IconThemeData(color: Colors.grey),
                    backgroundColor: Color(0xff62B47F),
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
                      _commonBottomNavigationBarItem(
                          icon: Icons.add_a_photo,
                          iconSize: 27.0,
                          title: "Diagnosis"),
                      _commonBottomNavigationBarItem(
                          icon: Icons.attachment,
                          iconSize: 27.0,
                          title: "Reports"),
                      _commonBottomNavigationBarItem(
                          icon: Icons.add_alert, iconSize: 27.0, title: "Blog"),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  _commonBottomNavigationBarItem(
      {@required icon, @required iconSize, @required title}) {
    return BottomNavigationBarItem(
        icon: Icon(
          icon,
          size: iconSize,
        ),
        label: title);
  }
}
