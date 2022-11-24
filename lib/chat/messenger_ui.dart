import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/chat/bloc/chat_event.dart';
import 'package:xeplich/chat/chat_content.dart';
import 'package:xeplich/list_contacts/list_contacts.dart';
import 'package:xeplich/staff/staff.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/file_storage.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../tools/function.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_state.dart';

//danh sách các cuộc trò chuyện
class MessengerUI extends StatefulWidget {
  final String sender_uid;

  const MessengerUI({Key? key, required this.sender_uid}) : super(key: key);

  @override
  _MessengerUIState createState() => _MessengerUIState();
}

class _MessengerUIState extends State<MessengerUI> {
  final fireStore = FirebaseFirestore.instance;

  void listen() {
    var userQuery = fireStore
        .collection('chats')
        .doc(widget.sender_uid)
        .collection('admin');

    userQuery.snapshots().listen((data) {
      data.docChanges.forEach((change) {
        showToast('có tin nhắn', null);
        print('có tin nhắn');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);

    List list_users = [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tin Nhắn', style: titleAppBar,
        ),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY,
        iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
      ),
      body: BlocProvider<ChatBloc>(
        create: (context) => ChatBloc(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: DefaultPadding / 2),
          child: Column(
            children: [
              FormSearch(),
          BlocBuilder<ChatBloc, ChatState>(
              builder: (context_2, state) {
                if(state is Loaded) {
                  return StreamBuilder(
                      stream: state.snapshot,
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        list_users.clear();
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LoadingScreen();
                        }

                        if (snapshot.data!.size == 0) {
                          return Text('Không cuộc trò chuyện nào');
                        }

                        var values = snapshot.data!.docs;
                        values.forEach((element) {
                          var data = element.data() as Map<String, dynamic>;
                          if (data['uid'] != widget.sender_uid)
                            list_users.add(data);
                        });

                        return Expanded(
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              // shrinkWrap: true,
                              itemCount: list_users.length, //bỏ current user
                              itemBuilder: (BuildContext context, int index) {
                                return cardMemberItem(
                                    context, list_users[index], size,
                                    themeData);
                              }),
                        );
                      });
                } return CircularProgressIndicator();
              }
          )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          widget.sender_uid == 'admin' ? Navigator.push(context, MaterialPageRoute(builder: (context) => Staff()))
          : Navigator.push(context, MaterialPageRoute(builder: (context) => ListContacts(uid_sender: widget.sender_uid)));
        },
        child: Icon(Icons.add, size: 30,),
        backgroundColor: COLOR_PRIMARY_1,
      ),
    );
  }

  //thẻ hiển thị thông tin 1 cuộc trò chuyện (listTile)
  InkWell cardMemberItem(
      BuildContext context, dynamic info_data, Size size, ThemeData themeData) {
    DateFormat dateFormat = DateFormat("HH:mm  dd-MM-yy");

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatContent(
                      sender_uid: widget.sender_uid,
                      info_data: info_data,
                    )));
      },
      child: StreamBuilder(
          stream: fireStore
              .collection('chats')
              .doc(widget.sender_uid)
              .collection(info_data['uid'])
              .orderBy('time')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            String message_content = 'Chưa có cuộc trò chuyện nào';
            String time = '';

            if (snapshot.hasData) {
              if (snapshot.data!.size != 0) {
                var value = snapshot.data!.docs.last;
                message_content = value.get('content');
                var date = DateTime.fromMillisecondsSinceEpoch(
                    value.get('time').millisecondsSinceEpoch);
                time = dateFormat.format(date);

                return Container(
                  height: size.width / 5,
                  margin: EdgeInsets.all(5.0),
                  padding: EdgeInsets.all(DefaultPadding - 5.0),
                  decoration: BoxDecoration(
                      color: info_data['name'] == 'ADMIN'
                          ? COLOR_PRIMARY_3
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          cacheImgAvt(info_data['email'].toString(), 30),
                          addHorizontalSpace(DefaultPadding),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                info_data['name'],
                                style: themeData.textTheme.headline4,
                              ),
                              addVerticalSpace(DefaultPadding / 4),
                              Expanded(
                                child: Container(
                                  width: size.width * 0.4,
                                  child: Text(
                                    message_content,
                                    style: time != ''
                                        ? TextStyle(fontWeight: FontWeight.w300)
                                        : TextStyle(color: COLOR_CONTRAST),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Text(
                        time,
                        style: TextStyle(fontWeight: FontWeight.w300),
                      )
                    ],
                  ),
                );
              }
              return SizedBox(width: 0, height: 0,);

            }
            return Container(
              height: size.width / 5,
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.all(DefaultPadding - 5.0),
              decoration: BoxDecoration(
                  color: info_data['name'] == 'ADMIN'
                      ? COLOR_PRIMARY_3
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/default_avatar.jpg'),
                        radius: 30,
                      ),
                      addHorizontalSpace(DefaultPadding),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 10,
                            color: COLOR_GREY,
                          ),
                          addVerticalSpace(DefaultPadding / 4),
                          Container(
                            width: 120,
                            height: 10,
                            color: COLOR_GREY,
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class FormSearch extends StatelessWidget{
  TextEditingController key_search = TextEditingController();

  @override
  Widget build(BuildContext context) {
      Size size = MediaQuery.of(context).size;
      final ChatBloc chatBloc = BlocProvider.of<ChatBloc>(context);

      return Container(
        width: size.width,
        height: 60,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: size.width - 5.0*2,
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: DefaultPadding/2),
            decoration: BoxDecoration(
              color: COLOR_PRIMARY_4,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow:  [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: TextField(
              onChanged: (keyword){
                chatBloc.add(UpdateData(keyword));
              },
              controller: key_search,
              autocorrect: false,
              cursorColor: COLOR_PRIMARY_1,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                icon: Icon(Icons.search, color: Colors.white),
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(fontWeight: FontWeight.w400),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: FontSizeNormal, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      );
  }
}

