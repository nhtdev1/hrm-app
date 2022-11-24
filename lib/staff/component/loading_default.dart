import 'package:flutter/material.dart';

import '../../tools/const.dart';

class LoadingDefault extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
      return Container(
        child: Column(
          children: [
            Container(
              height: size.height * 0.15,
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
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0))),
            ),
            Padding(
              padding: EdgeInsets.only(top: DefaultPadding),
              child: CircularProgressIndicator(color: COLOR_PRIMARY_1),
            )
          ],
        ),
      );
  }
}