import 'package:xeplich/change_pass/change_pass.dart';
import 'package:xeplich/chart/ChartPage.dart';
import 'package:xeplich/homescreen/components/user_page.dart';
import 'package:xeplich/login/login.dart';
import 'package:xeplich/staff/member_details.dart';
import 'package:xeplich/test/test.dart';
import 'package:xeplich/tools/app_info.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final String? name;
  final String? no;
  final String? uid;
  final String? email;

  const NavigationDrawerWidget(
      {Key? key, this.uid, this.name, this.no, this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    Size size = MediaQuery.of(context).size;
    double ndw_width;

    final String _name, _no, _email;

    if (name != null && no != null) {
      _name = name!;
      _no = no!;
      _email = email!;
      ndw_width = size.width * 0.7;
    } else {
      _name = 'ADMIN';
      _no = '_';
      _email = 'admin@gmail.com';
      ndw_width = size.width * 0.6;
    }

    return Container(
      width: ndw_width,
      child: Drawer(
        child: Material(
          color: COLOR_PRIMARY,
          child: ListView(
            children: <Widget>[
              buildHeader(
                  name: _name,
                  id: _no,
                  width: ndw_width,
                  email: _email,
                  onClicked: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserPage(
                                  name: _name,
                                  email: _email,
                                )));
                  }),
              addLine(0),
              if (_name != 'ADMIN')
                buildMenuItem(
                    text: 'Hồ sơ',
                    icon: Icons.person,
                    onClicked: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MemberDetails(uid: uid!)));
                    }),
              // if (_name == 'ADMIN')
              //   buildMenuItem(
              //       text: 'Thống kê',
              //       icon: Icons.bar_chart,
              //       onClicked: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => uid != null
              //                     ? ChartPage(uid: uid!)
              //                     : ChartPage(uid: 'admin')));
              //       }),
              buildMenuItem(
                  text: 'Đăng xuất',
                  icon: Icons.logout,
                  onClicked: () {
                    Navigator.pop(context);
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                'Xác nhận',
                                style: titleText,
                              ),
                              content: Text(
                                'Đăng xuất không?',
                                style: TextStyle(fontSize: 18),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context, 'OK');
                                    _auth.signOut(); //đăng xuất current users

                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    pref.clear(); //xóa dữ liệu đăng nhập shared preferences

                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Login()),
                                        (route) => false);
                                    showToast(_name + ' đã đăng xuất', null);
                                  },
                                  child: const Text('OK'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Hủy'),
                                  child: const Text('Hủy'),
                                ),
                              ],
                            ));
                  }),
              buildMenuItem(
                  text: 'Đổi mật khẩu',
                  icon: Icons.lock_outline,
                  onClicked: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => uid != null
                                ? ChangePassword(uid: uid!)
                                : ChangePassword(uid: 'admin')));
                  }),
              buildMenuItem(
                  text: 'Thông tin ứng dụng',
                  icon: Icons.info_outline,
                  onClicked: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AppInfo()));
                  }),
              // buildMenuItem(text: 'Test', icon: Icons.warning_amber_outlined, onClicked: (){
              //   Navigator.push(context, MaterialPageRoute(builder: (context)
              //   => Test()));
              // })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(
      {required String text, required IconData icon, VoidCallback? onClicked}) {
    final color = COLOR_PRIMARY_1;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onClicked,
    );
  }

  Widget buildHeader(
      {required double width,
      required String name,
      required String id,
      required String email,
      required VoidCallback onClicked}) {
    return InkWell(
      onTap: onClicked,
      child: Container(
        //color: COLOR_PRIMARY.withOpacity(0.5),
        padding: EdgeInsets.all(DefaultPadding),
        child: Row(
          children: [
            SizedBox(
              width: width * 0.3 - DefaultPadding,
              child: cacheImgAvt(email, 30),
            ),
            addHorizontalSpace(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * 0.7 - DefaultPadding * 2,
                  child: Text(name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(3.0, 4.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 129, 156, 245),
                          ),
                        ],
                      )),
                ),
                if (name != 'ADMIN') Text(id)
              ],
            )
          ],
        ),
      ),
    );
  }
}
