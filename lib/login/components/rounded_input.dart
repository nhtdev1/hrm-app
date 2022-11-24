import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';

class Rounded_Input extends StatelessWidget {
  final Icon? icon;
  final String hintText;
  final TextEditingController? textController;
  final bool? hide;

  Rounded_Input({Key? key, this.icon, required this.hintText, this.textController, this.hide})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DefaultPadding),
      height: MediaQuery.of(context).size.width * 0.8 * 0.15,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: Colors.white),
      child: Center(
        child: Theme(
          data:Theme.of(context).copyWith(
            colorScheme: ThemeData().colorScheme.copyWith(
              primary: COLOR_PRIMARY_1,
            ),
          ),
          child: TextField(
            controller: textController,
            autocorrect: false,
            cursorColor: COLOR_PRIMARY_1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              icon: icon == null ? null : icon,
              hintText: hintText,
              hintStyle: TextStyle(fontWeight: FontWeight.w400),
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: FontSizeNormal, fontWeight: FontWeight.w600),
            obscureText: hide == true ? true : false,
          ),
        ),
      ),
    );
  }
}
