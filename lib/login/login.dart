import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/homescreen/homescreen_admin.dart';
import 'package:xeplich/homescreen/homescreen_staff.dart';
import 'package:xeplich/login/components/rounded_input.dart';
import 'package:xeplich/services/local_notification_service.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/tools/giai_thuat_sap_lich.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xeplich/tools/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Impotance Notification',
//   importance: Importance.high,
//   playSound: true
// );
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _passController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool? isLoading;

  String name = '';
  String no = '';

  final _auth = FirebaseAuth.instance;

  Future getData(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      var data = value.data() as Map<String, dynamic>;
      name = data['name'];
      no = data['no'];
    });
  }

  Future login(String email, String pass) async {
    String passMD5 = generateMd5(pass);
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: passMD5)
          .then((value) async {
        final pref = await SharedPreferences.getInstance();
        await pref.setString("user_id", value.user!.uid);
        await pref.setString("user_email", value.user!.email!);
        if (value.user!.email == 'admin@gmail.com') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
          showToast('Xin ch??o ADMIN', null);
        } else {
          await getData(value.user!.uid).whenComplete(() async {
            //L??u d??? li???u phi??n ????ng nh???p
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setStringList('login', [value.user!.uid, name, no, email]);

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreenStaff(
                          uid: value.user!.uid,
                          name: name,
                          no: no,
                          email: email,
                        )),
                (route) => false);
            showToast(name + ' ???? ????ng nh???p', null);
          });
        }
      });
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'user-not-found':
          showToast('T??i kho???n kh??ng t???n t???i :(((', null);
          break;
        case 'wrong-password':
          showToast('M???t kh???u sai', null);
          break;
        default:
          showToast(error.code, null);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    LocalNotificationService.initialize(context);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data['route'];
        Navigator.of(context).pushNamed(routeFromMessage);
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body);
        print(message.notification!.title);
      }
      LocalNotificationService.display(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data['route'];
      print(routeFromMessage);
      Navigator.of(context).pushNamed(routeFromMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final loginProvider = Provider.of<AuthService>(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          color: COLOR_PRIMARY,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon_app.png',
                      width: size.width * 0.28,
                    ),
                    addVerticalSpace(size.height * 0.03),
                    Text(
                      'Qu???n L?? L???ch L??m',
                      style: TextStyle(
                        fontSize: size.width * 0.09,
                        color: COLOR_PRIMARY_1,
                        fontWeight: FontWeight.w900,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(5.0, 5.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ],
                      ),
                    ),
                    addVerticalSpace(size.height * 0.015),
                    Text(
                      'QU??N ??N ?????U ?????U',
                      style: TextStyle(
                          color: COLOR_CONTRAST,
                          fontSize: 28,
                          fontWeight: FontWeight.w900),
                    ),
                    addVerticalSpace(size.height * 0.1),
                    Form(
                      child: Column(
                        children: [
                          Rounded_Input(
                            icon: Icon(Icons.email_rounded),
                            hintText: 'Email',
                            textController: _emailController,
                          ),
                          addVerticalSpace(DefaultPadding),
                          Rounded_Input(
                            icon: Icon(Icons.lock),
                            hintText: 'M???t kh???u',
                            textController: _passController,
                            hide: true,
                          ),
                          addVerticalSpace(DefaultPadding),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus(); //???n b??n ph??m
                        if (_emailController.text.trim() != '') {
                          if (!_emailController.text.trim().isValidEmail)
                            showToast('Email kh??ng h???p l???', null);

                          if (_passController.text.trim() != '') {
                            setState(() {
                              isLoading = true;
                            });
                            login(_emailController.text.trim(),
                                    _passController.text.trim())
                                .whenComplete(() {
                              setState(() {
                                isLoading = false;
                              });
                            });
                            GiaiThuat().lichRanh_databaseToFile();
                            GiaiThuat().lichRanh_old_databaseToFile();
                            GiaiThuat().name_databaseToFile();
                          } else
                            showToast('Vui l??ng nh???p m???t kh???u', null);
                        } else {
                          if (_passController.text.trim() != '')
                            showToast('B???n ch??a nh???p email', null);
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.8 * 0.15,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: COLOR_PRIMARY_1,
                        ),
                        child: Center(
                            child: isLoading != true
                                ? Text('????NG NH???P',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700))
                                : SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white))),
                      ),
                    ),
                    addVerticalSpace(size.width * 0.1),
                    SizedBox(
                        width: size.width * 0.9,
                        child: Text(
                          'S??? d???ng t??i kho???n v?? m???t kh???u do ADMIN cung c???p ????? ????ng nh???p',
                          style: TextStyle(
                              fontSize: size.width * 0.038, color: Colors.grey),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
              Positioned(
                  bottom: DefaultPadding,
                  width: size.width,
                  child: Center(
                    child: Text(
                      '?? Nguy???n Tr???n B??ch Khu??\nPhi??n b???n: 1.0',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
