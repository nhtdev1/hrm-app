import 'package:xeplich/chat/messenger_ui.dart';
import 'package:xeplich/post/post.dart';
import 'package:xeplich/schedule/schedule_staff/schedule_staff.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/note/note.dart';
import 'package:xeplich/schedule/view_schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridviewItem extends StatelessWidget{
  final int index;
  final String title;
  final String subTitle;
  final String imgBgr;
  final String? uid;
  final String email;

  GridviewItem({
    Key? key,
    required this.index,
    required this.title,
    required this.subTitle,
    required this.imgBgr,
    this.uid,
    required this.email,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    // TODO: implement build
    return InkWell(
      onTap: (){goDetailPage(context, index);},
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              //color: Colors.grey.withOpacity(0.3),
              color: COLOR_PRIMARY.withOpacity(0.7),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(2, 5), // changes position of shadow
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(DefaultPadding),
          //color: Colors.white,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(color: COLOR_PRIMARY_1, width: 0.2),
              image: DecorationImage(
                image: AssetImage(imgBgr),
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
              )
          ),
          child: Column(
            children: [
              Text(title, style: themeData.textTheme.headline1!.copyWith(
                  shadows: [
                    Shadow( // bottomLeft
                        offset: Offset(-1.5, -1.5),
                        color: Colors.white
                    ),
                    Shadow( // bottomRight
                        offset: Offset(1.5, -1.5),
                        color: Colors.white
                    ),
                    Shadow( // topRight
                        offset: Offset(1.5, 1.5),
                        color: Colors.white
                    ),
                    Shadow( // topLeft
                        offset: Offset(-1.5, 1.5),
                        color: Colors.white
                    ),
                  ]
              )),
              addVerticalSpace(DefaultPadding),
              Text(subTitle, style: themeData.textTheme.headline5)
            ],
          ),
        ),
      ),
    );
  }

  goDetailPage(BuildContext context, int index){
    switch (index){
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewSchedule(isAdmin: false, uid_staff: uid!,)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScheduleStaff(uid: uid!,)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MessengerUI(sender_uid: uid!,)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Post(uid: uid!, email: email,)),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Note(uid: uid!,)),
        );
        break;
    }
  }
}