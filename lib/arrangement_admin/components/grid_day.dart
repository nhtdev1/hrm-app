import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';

class GridviewDay extends StatelessWidget {
  final String item;

  const GridviewDay({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(DefaultPadding / 5),
      padding: EdgeInsets.all(DefaultPadding /5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        border: Border.all(color: COLOR_PRIMARY_1, width: 2),
      ),
      child: Text(
        item,
        style: TextStyle(color: COLOR_PRIMARY_1),
      ),
    );
  }
}
