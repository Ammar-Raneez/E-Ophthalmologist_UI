import 'package:flutter/cupertino.dart';

class EditReportScreen extends StatefulWidget {
  static String id = "editReportScreen";

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    return Container(
      child: Text("edit report")
    );
  }
}
