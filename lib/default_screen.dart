import 'package:xeplich/homescreen/homescreen_admin.dart';
import 'package:xeplich/homescreen/homescreen_staff.dart';
import 'package:xeplich/login/login.dart';
import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultScreen extends StatefulWidget {
  @override
  _DefaultScreenState createState() => _DefaultScreenState();
}

class _DefaultScreenState extends State<DefaultScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: COLOR_PRIMARY,
          child: Center(
              child: Image.asset(
            'assets/icon_app.png',
            width: 200.0,
          )),
        ));
  }
}
