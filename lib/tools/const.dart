import 'package:flutter/material.dart';

const COLOR_PRIMARY = Color.fromRGBO(212, 217, 255, 1.0);
const COLOR_PRIMARY_1 = Color.fromRGBO(78, 59, 118, 1.0);
const COLOR_PRIMARY_2 = Color.fromRGBO(123, 81, 203, 1.0);
const COLOR_PRIMARY_3 = Color.fromRGBO(236, 234, 250, 1.0);
const COLOR_PRIMARY_4 = Color.fromRGBO(98, 90, 170, 1.0);
const COLOR_CONTRAST = Color.fromRGBO(243, 185, 14, 1.0);
const COLOR_CONTRAST_1 = Color.fromRGBO(255, 233, 77, 1.0);
const COLOR_CONTRAST_2 = Color.fromRGBO(182, 136, 2, 1.0);
const COLOR_GREY = Color.fromRGBO(204, 204, 204, 0.8);


const DefaultPadding = 20.0;
const FontSizeNormal = 18.0;
const paddingContainer = 10.0;

const TextStyle labelText = TextStyle(color: COLOR_PRIMARY_1, fontWeight: FontWeight.w500);
const TextStyle titleText = TextStyle(color: COLOR_PRIMARY_1, fontWeight: FontWeight.w500, fontSize: 20);
const TextStyle requiredText =  TextStyle(color: Colors.red);
const TextStyle titleAppBar = TextStyle(color: COLOR_PRIMARY_1, fontWeight: FontWeight.bold, letterSpacing: 1, wordSpacing: 5, fontSize: 23);

const TextTheme TEXT_THEME_DEFAULT = TextTheme(
  headline1: TextStyle(
    color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 26
  ),
  headline2: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 23
  ),
  headline3: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 20
  ),
  headline4: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 18
  ),
  headline5: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w600, fontSize: 15
  ),
  headline6: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w600, fontSize: 12
  ),
  bodyText1: TextStyle(
      color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 14, height: 1.5
  ),
  bodyText2: TextStyle(
      color: Colors.black, fontWeight: FontWeight.w400, fontSize: 14, height: 1.5
  ),
  subtitle1: TextStyle(
      color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 12
  ),
  subtitle2: TextStyle(
      color: Colors.black, fontWeight: FontWeight.w300, fontSize: 12
  ),
);

const TextTheme TEXT_THEME_SMALL = TextTheme(
  headline1: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 22
  ),
  headline2: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 20
  ),
  headline3: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 18
  ),
  headline4: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 15
  ),
  headline5: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 12
  ),
  headline6: TextStyle(
      color: COLOR_PRIMARY_1, fontWeight: FontWeight.w700, fontSize: 10
  ),
  bodyText1: TextStyle(
      color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12, height: 1.5
  ),
  bodyText2: TextStyle(
      color: Colors.black, fontWeight: FontWeight.w500, fontSize: 12, height: 1.5
  ),
  subtitle1: TextStyle(
      color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 10
  ),
  subtitle2: TextStyle(
      color: Colors.black, fontWeight: FontWeight.w300, fontSize: 10
  ),
);