import 'package:xeplich/login/components/rounded_input.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/tools/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class Test extends StatefulWidget{
  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  String MD5 = '';

  String s2 = 'huhu';

  TextEditingController pass = TextEditingController();

  Future printS2() async {
    print(await http.read(Uri.parse('https://flutter.dev/')));
  }

  // int print_1(){
  //   int max;
  //   int kq = [(max > 100) ? max : 100] ?? 100;
  //   return kq;
  // }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    DateFormat dateFormat = DateFormat("HH:mm");
    // String now = dateFormat.format(DateTime.now());
    print(DateTime.now().minute);
    return Scaffold(
      body: Container(
        width: size.width,
        color: Colors.greenAccent,
        child: Column(
          children: [
            Rounded_Input(hintText: 'Nhập', textController: pass,),
            ElevatedButton(
                onPressed: () {
                  // PushNotificationService().addNotification('test', 'test thông báo');
                  // setState(() {
                  //   MD5 = generateMd5(pass.text);
                  //   printS2();
                  // });
                  // print(print_1());
                },
                child: Text('show')
            ),
            Text(MD5),
          ],
        ),
      ),
    );
  }
}