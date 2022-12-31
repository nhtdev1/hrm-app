import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'components/body.dart';

//Nội dung cuộc trò chuyện
class ChatContent extends StatefulWidget{
  final String sender_uid;
  final dynamic info_data;

  ChatContent({Key? key, required this.info_data, required this.sender_uid}) : super(key: key);

  @override
  _MessengerState createState() => _MessengerState();
}

class _MessengerState extends State<ChatContent> {
  final String urlAvt = 'https://ss-images.saostar.vn/pc/1605234579397/z2174715918193_7a8c2d1a36fa6b98074de65420dcb7dd(1).jpg';
  final fb = FirebaseDatabase.instance;
  final fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return StreamBuilder(
      stream: fireStore.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  cacheImgAvt(widget.info_data['email'], 23),
                  addHorizontalSpace(DefaultPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.info_data['name'], style: themeData.textTheme.headline4,),
                      Text(widget.info_data['no'], style: themeData.textTheme.bodyText1),
                    ],
                  )
                ],
              ),
              iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
              backgroundColor: COLOR_PRIMARY_3,
              // actions: [
              //   Icon(Icons.local_phone),
              //   addHorizontalSpace(DefaultPadding),
              //   Icon(Icons.info_outline_rounded),
              //   addHorizontalSpace(DefaultPadding),
              // ],
            ),
            body: Body(uid_sender: widget.sender_uid, uid_reciever: widget.info_data['uid'], email: widget.info_data['email']),
          );
        }
        else return Container(
            color: Colors.white,
            child: Center(
                child: CircularProgressIndicator()));
      }
    );
  }
}