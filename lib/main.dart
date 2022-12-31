import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:xeplich/default_screen.dart';
import 'package:xeplich/homescreen/homescreen_admin.dart';
import 'package:xeplich/homescreen/homescreen_staff.dart';
import 'package:xeplich/post/PostDoc.dart';
import 'package:xeplich/post/post.dart';
import 'package:xeplich/schedule/view_schedule.dart';
import 'package:xeplich/services/local_notification_service.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/tools/giai_thuat_sap_lich.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xeplich/tools/push_notification_service.dart';
import 'login/login.dart';

//recieve message when app is in the background
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final fireStore = FirebaseFirestore.instance;

  String? uid, name, no, email;
  int? notificationType;

  Future<int> checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List? val = pref.getStringList('login');
    if (val == null)
      return -1; //nếu chưa đăng nhập, shared preferences ko có dữ liệu
    else if (val[0] == 'admin')
      return 0; //nếu là admin
    else {
      uid = val[0];
      name = val[1];
      no = val[2];
      email = val[3];
      return 1;
    } // nếu là nhân viên
  }

  //load avatar từ database về
  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result =
        await FirebaseStorage.instance.ref().child('avt').list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description',
        "byteCode": await file.getData()
      });
    });
    return files;
  }

  void updateSchedule() {
    DateTime today = DateTime.now();
    int Thu = today.weekday; // 0 = Sun, 6 = Sat
    String lichDuKien = '';
    if (Thu == 1) {
      FirebaseFirestore.instance
          .collection('lich')
          .doc('lich')
          .get()
          .then((value) {
        value.data()!.forEach((key, value) {
          if (key == 'lichDuKien') {
            lichDuKien = value;
          }
        });
        if (lichDuKien != '-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_') {
          FirebaseFirestore.instance.collection('lich').doc('lich').update({
            'lichChinhThuc': lichDuKien,
            'lichDuKien': '-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
          });
        }
      });

      var ref = FirebaseFirestore.instance
          .collection('users')
          .orderBy('no', descending: false);
      ref.get().then((QuerySnapshot snapshot) {
        var values = snapshot.docs;
        values.forEach((element) {
          var data = element.data() as Map<String, dynamic>;
          if (data['no'] != '000') {
            FirebaseFirestore.instance
                .collection('users')
                .doc(data['uid'])
                .update({
              'lichRanh_old': data['lichRanh'],
              'lichRanh': '000000000000000000000',
            });
          }
        });
      });
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    updateSchedule();
    GiaiThuat().name_databaseToFile();
    GiaiThuat().lichRanh_databaseToFile();
    GiaiThuat().lichRanh_old_databaseToFile();
    double screenWidth = window.physicalSize.width;
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: screenWidth < 500 ? TEXT_THEME_SMALL : TEXT_THEME_DEFAULT,
        fontFamily: "Montserrat",
      ),
      home: FutureBuilder<int>(
        future: checkLogin(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case -1:
                return Login();
              case 0:
                return HomeScreen();
              case 1:
                return HomeScreenStaff(
                  uid: uid!,
                  name: name!,
                  no: no!,
                  email: email!,
                );
            }
          }
          return DefaultScreen();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setupNotification();
  }

  Future<void> setupNotification() async {
    final pref = await SharedPreferences.getInstance();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon_app');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: (int id, String? title, String? body,
                String? payload) async {});
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      String userId = pref.getString("user_id") ?? "";
      if (userId.isNotEmpty) {
        if (notificationType != null && notificationType == 1) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (context) => ViewSchedule(
                      isAdmin: false,
                      uid_staff: userId,
                    )),
          );
        } else if (notificationType != null && notificationType == 2) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (context) => Post(uid: uid!, email: '')),
          );
        }
      }
    });

    fireStore.collection('lich').doc('lich').snapshots().listen((event) {
      String username = pref.getString("user_email") ?? "";
      if (username.isNotEmpty && username != 'admin@gmail.com') {
        notificationType = 1;
        PushNotificationService().addNotification('Lịch Làm Hằng Tuần',
            'Quản lý đã cập nhật lịch làm cho tuần mới. Nhấn vào xem');
      }
    });

    fireStore.collection('post').snapshots().listen((event) async {
      PostDoc lastPCurrent = await getLastPostTimestamp();
      PostDoc lastPPrevious = PostDoc.fromPref(
          pref.getString("last_post") == null
              ? {}
              : jsonDecode(pref.getString("last_post")!));
      if (lastPCurrent.createdAt > lastPPrevious.createdAt) {
        notificationType = 2;
        await pref.setString("last_post", jsonEncode(lastPCurrent.toJson()));
        PushNotificationService().addNotification('Bài viết mới',
            '${lastPCurrent.name} đã vừa đăng một bài viết mới. Nhấn vào xem');
      }
    });
  }

  Future<PostDoc> getLastPostTimestamp() async {
    var lastPost = (await fireStore
            .collection("post")
            .orderBy("time", descending: true)
            .limit(1)
            .snapshots()
            .first)
        .docs
        .last;
    PostDoc postDoc = PostDoc.fromJson(lastPost.data());
    return postDoc;
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
