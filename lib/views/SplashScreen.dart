import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kook/Widgets/SplashScreenButton.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  Timer _timer;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    _timer = Timer(Duration(seconds: 5), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset("assets/images/app_logo.png"),
          ),
          AnimatedOpacity(
            duration: Duration(seconds: 2),
            opacity: _opacity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SplashScreenButtons(
                          buttonColor: Color(0xff0846BD),
                          buttonText: "S'authentifier avec Facebook",
                          textColor: Colors.white,
                        ),
                      ),
                      SplashScreenButtons(
                        buttonColor: Color(0xffE5E5E5),
                        buttonText: "S'authentifier avec E-mail",
                      ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
