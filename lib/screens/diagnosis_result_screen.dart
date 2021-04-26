import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ui/components/custom_rounded_button.dart';
import 'package:ui/constants.dart';

class DiagnosisResultScreen extends StatefulWidget {
  static String id = 'diagnosisResultScreen';

  @override
  _DiagnosisResultScreenState createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  Map insights = {
    "No Diabetic Retinopathy":
        "Continue regular scanning and monitoring to prevent form sight threatening retinopathy. Keep your blood sugar, blood pressure, and cholesterol levels under control.",
    "Mild": """
      You've been diagnosed with the first stage of retinopathy also called background retinopathy
      You probably won't have vision problems, so you may not need treatment. 
      But consult your doctor about ways to keep your condition from getting worse.
      Keep your blood sugar, blood pressure, and cholesterol levels under control.
      If the condition is diagnoses in both eyes,
      you have a 25% chance of progressing to the third stage in the next 3 years.
    """,
    "Moderate": """
      You've been diagnosed with the second stage of retinopathy also called pre-proliferative retinopathy
      At this stage, the blood vessels in your retinas swell. Physical changes are caused to the retina.
      Reaching this stage means a greater chance that the disease will affect your vision. 
      Consult your ophthalmologist or optometrist; they may recommend eye tests every 3 to 6 months.
    """,
    "Severe": """
      This is also called proliferative retinopathy. In this stage, your blood vessels become even more blocked. 
      There’s a very high chance that you’ll lose your vision. Treatment may be able to stop further vision loss. 
      But if you’ve already lost some of your vision, it’s unlikely to come back.
      Consult your ophthalmologist or optometrist on future clarification.
    """,
    "Proliferative": """"
      You are diagnosed with the advanced stage of retinopathy.
      Neovascularization happened due to the growth of new blood vessels in your retinas.
      Due to retinal detachment, there is a high chance of permanent loss of both straight-ahead and side vision. 
      Consult your ophthalmologist or optometrist immediately to get the necessary treatment.
    """
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;
    var height = screenSize.height;
    // get values of the arguments passed
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    String datetime = DateTime.fromMillisecondsSinceEpoch(
                arguments['time'].seconds * 1000)
            .day
            .toString() +
        "-" +
        DateTime.fromMillisecondsSinceEpoch(arguments['time'].seconds * 1000)
            .month
            .toString() +
        "-" +
        DateTime.fromMillisecondsSinceEpoch(arguments['time'].seconds * 1000)
            .year
            .toString();

    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: Text(
                "E-Ophthalmologist",
                style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white),
              ),
            ),
            backgroundColor: Color(0xff62B47F),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Diagnosis",
                  style: kTextStyle.copyWith(fontSize: 30.0),
                  textAlign: TextAlign.center,
                ),
                Center(
                  child: CachedNetworkImage(
                    // display a loading spinner while the image downloads and displays
                    // from the argument url
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
                      width: width / 2,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                    ),
                    imageUrl: arguments['image_url'],
                    width: width,
                    height: height / 2.2,
                  ),
                ),
                _commonLabelText(
                    sentence: "Scan on: $datetime",
                    textColor: Colors.black,
                    fontSize: 20.0),
                _commonLabelText(
                    sentence:
                        "A ${arguments['result']} condition has been detected in the above retinal fundus",
                    textColor: Colors.red,
                    fontSize: 20.0),
                _commonLabelText(
                    sentence: insights[arguments['result']],
                    textColor: Colors.black54,
                    fontSize: 15.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomRoundedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    colour: Color(0xff62B47F),
                    title: "<-  Back to Home",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _commonLabelText(
      {@required String sentence,
      @required Color textColor,
      @required fontSize}) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            "$sentence",
            style: kTextStyle.copyWith(color: textColor, fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 50,
        )
      ],
    );
  }
}
