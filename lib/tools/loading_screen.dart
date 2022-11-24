import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(color: COLOR_PRIMARY_1, strokeWidth: 4,),
        ),
      );
  }
  
}