import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';

import 'function.dart';

class AppInfo extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: COLOR_PRIMARY,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon_app.png', width: size.width * 0.28,),
            addVerticalSpace(size.height * 0.03),
            Text('Quản Lý Nhân Sự', style: TextStyle(fontSize: size.width * 0.09, color: COLOR_PRIMARY_1, fontWeight: FontWeight.w900,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(5.0, 5.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ],
            ),),
            addVerticalSpace(size.height * 0.015),
            Text('QUÁN ĂN ĐẬU ĐẬU', style: TextStyle(color: COLOR_CONTRAST, fontSize: 28, fontWeight: FontWeight.w900,  wordSpacing: size.width * 0.03)),
            addVerticalSpace(size.height * 0.1),
            Text('GVHD: TS.Phạm Thủy Tú'),
            Text('Copyright Nguyễn Trần Bích Khuê'),
            Text('Phiên bản: 1.0')
          ],
        ),
      ),
    );
  }

}