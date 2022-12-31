import 'package:xeplich/homescreen/components/gridview_item_admin.dart';
import 'package:xeplich/homescreen/components/header.dart';
import 'package:xeplich/tools/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import '../schedule/view_schedule.dart';
import 'components/navigation_drawer_widget.dart';

class HomeScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    final List<MenuItem> menuItem = [
      MenuItem(title: 'Quản Lý Lịch Làm', subTitle: 'Xem và sắp xếp lịch làm của các tuần', imgBgr: 'assets/img3.jpg'),
      // MenuItem(title: 'Sắp Xếp', subTitle: 'Sắp xếp nhân sự cho tuần sau', imgBgr: 'assets/img4.png'),
      MenuItem(title: 'Quản Lý Nhân Viên', subTitle: 'Xem và chỉnh sửa thông tin nhân viên', imgBgr: 'assets/img7.jpg'),
      MenuItem(title: 'Tin Nhắn', subTitle: 'Liên lạc với các thành viên khác', imgBgr: 'assets/img9.png'),
      MenuItem(title: 'Bài Đăng', subTitle: 'Xem và chia sẻ công khai các bài viết', imgBgr: 'assets/img5.jpg'),
      MenuItem(title: 'Ghi Chú', subTitle: 'Xem và tạo các ghi chú', imgBgr: 'assets/img10.jpg'),
    ];
    
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: COLOR_PRIMARY,
          title: Text('ADMIN', style: titleAppBar),
          centerTitle: true,
          iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
          actions: [
            IconButton(
                onPressed: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewSchedule(isAdmin: true)),
                  );
                },
                icon: Icon(Icons.calendar_today_rounded)
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Header(),
            Expanded(
              child: GridView.count(
                physics: BouncingScrollPhysics(),
                crossAxisCount: 1,
                padding: EdgeInsets.all(DefaultPadding),
                crossAxisSpacing: DefaultPadding *2,
                mainAxisSpacing: DefaultPadding *2,
                children: menuItem.map((item) {
                  int index = menuItem.indexOf(item);
                  return
                    GridviewItem(index: index,
                        title: item.title,
                        subTitle: item.subTitle,
                        imgBgr: item.imgBgr);
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _openBrowser() async {
    try {
      final int result = await SystemChannels.platform.invokeMethod(
          'openBrowser', <String, String>{
          'url': "https://flutter.dev"
        }
      );

      // await SystemChannels.platform.invokeMethod(
      //     'openPhoneCall'
      // );
    }
    on PlatformException catch (e) {
      // Unable to open the browser
      print(e);
    }
  }
}

class MenuItem {
  final String title;
  final String subTitle;
  final String imgBgr;

  MenuItem({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.imgBgr,
  });
}