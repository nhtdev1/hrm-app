import 'package:xeplich/post/edit_post.dart';
import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';
import '../../tools/function.dart';

class Header extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double header_height = size.height * 0.27;
    final ThemeData themeData = Theme.of(context);

    // TODO: implement build
    return Stack(
      children: <Widget>[
        Container(
          height: header_height,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            boxShadow:  [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            color: COLOR_PRIMARY,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
          ),
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: DefaultPadding * 1.3, horizontal: DefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QUẢN LÝ LỊCH LÀM', style: themeData.textTheme.headline3!.copyWith(color: COLOR_PRIMARY_1)),
                    addVerticalSpace(10),
                    Text('Quán Ăn Đậu Đậu', style: themeData.textTheme.headline1!.copyWith(color: COLOR_CONTRAST, letterSpacing: 3)),
                  ],
                ),

                // addVerticalSpace(10),
                SizedBox(
                    width: size.width * 0.5,
                    child: Text('Hãy để công việc của bạn dễ dàng và hiệu quả hơn', style: TextStyle(color: COLOR_PRIMARY_1))
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 10.0,
          bottom: 0.0,
          child: Container(
            width: size.width * 0.85,
            child: Center(
                child: Image.asset('assets/img8.png')),
          ),
          // width: 350,
        ),
      ],
    );
  }

}