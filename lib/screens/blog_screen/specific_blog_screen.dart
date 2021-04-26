import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ui/constants.dart';
import 'package:pdf_flutter/pdf_flutter.dart';

class SpecificBlogScreen extends StatefulWidget {
  static String id = "specificBlogScreen";

  @override
  _SpecificBlogScreenState createState() => _SpecificBlogScreenState();
}

class _SpecificBlogScreenState extends State<SpecificBlogScreen> {
  String pdfPath = "";
  bool showSpinner = false;
  bool isNetwork = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    setState(() {
      pdfPath = arguments['pdf'];
      isNetwork = arguments['isNetwork'];
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "E-Ophthalmologist",
            style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Color(0xff62B47F),
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: pdfPath == ""
              ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              : Container(
                  height: MediaQuery.of(context).size.height,
                  child: !isNetwork
                      ? PDF.asset(
                          pdfPath,
                        )
                      : PDF.network(pdfPath),
                ),
        ),
      ),
    );
  }
}
