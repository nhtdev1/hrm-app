import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';

class GridviewContent extends StatelessWidget{
  final String item;
  // final String? name;

  const GridviewContent({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      // onLongPress: item != name!.substring(name!.lastIndexOf(' '), name!.length) ? null : (){
      //   print('hey');
      // },
      child: Container(
        alignment: Alignment.center,
        //margin: EdgeInsets.all(DefaultPadding / 5),
        padding: EdgeInsets.all(DefaultPadding /5),
        decoration: BoxDecoration(
          color: COLOR_PRIMARY_1,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: COLOR_PRIMARY, width: 0.5),
        ),
        child: Text(
          item,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}