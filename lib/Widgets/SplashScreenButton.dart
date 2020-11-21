import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kook/Widgets/CircularIcon.dart';

class SplashScreenButtons extends StatelessWidget {
  final Color buttonColor;
  final String buttonText;
  final Widget buttonIcon;
  final Color textColor;

  SplashScreenButtons(
      {this.buttonColor,
      this.buttonIcon,
      this.buttonText,
      this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth - (screenWidth / 4),
      height: 40,
      decoration: BoxDecoration(
          color: this.buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, top: 5, right: 10, left: 10),
        child: Row(
          children: [
            CircularIcon(
                circleColor: Colors.white,
                icon: Icon(Icons.ac_unit_outlined, size: 15)),
            Padding(
              padding: const EdgeInsets.only(
                left: 10
              ),
              child: Text(this.buttonText, style: TextStyle(color: this.textColor)),
            )
          ],
        ),
      ),
    );
  }
}
