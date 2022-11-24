import 'package:xeplich/homescreen/homescreen_admin.dart';
import 'package:xeplich/login/test_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../login/login.dart';

class Wrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if(user != null){
      return HomeScreen();
    }
    else return Login();
  }
}