import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/homescreen/components/header.dart';
import 'package:xeplich/tools/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/gridview_item_staff.dart';
import 'components/navigation_drawer_widget.dart';

class HomeScreenStaff extends StatelessWidget{
  // final dynamic data;
  final String uid;
  final String name;
  final String no;
  final String email;

  const HomeScreenStaff({Key? key, required this.uid, required this.name, required this.no, required this.email}) : super(key: key);

  void getPref() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getStringList('login'));
  }

  @override
  Widget build(BuildContext context) {

    // getPref();
    final List<MenuItem> menuItem = [
      MenuItem(title: 'Xem Lịch', subTitle: 'Lịch làm của tuần này', imgBgr: 'assets/img3.jpg'),
      MenuItem(title: 'Quản Lý Lịch', subTitle: 'Đăng ký lịch rảnh mỗi tuần', imgBgr: 'assets/img4.png'),
      MenuItem(title: 'Tin Nhắn', subTitle: 'Trao đổi với admin và các thành viên khác', imgBgr: 'assets/img9.png'),
      MenuItem(title: 'Bài Đăng', subTitle: 'Xem và chia sẻ công khai các bài viết', imgBgr: 'assets/img5.jpg'),
      MenuItem(title: 'Ghi Chú', subTitle: 'Xem và tạo các ghi chú', imgBgr: 'assets/img10.jpg'),
    ];

    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        drawer: NavigationDrawerWidget(uid: uid, name: name, no: no, email: email,),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: COLOR_PRIMARY,
          title: Text(name, style: titleAppBar),
          centerTitle: true,
          iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.calendar_today_rounded))
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
                      imgBgr: item.imgBgr,
                      uid: uid,
                      email: email,
                      // data: data,
                    );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
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