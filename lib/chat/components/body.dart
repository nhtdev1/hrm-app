import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/chat/components/message_content_wrap.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:flutter/material.dart';
import 'chat_input_field.dart';

//khung hiển thị cuộc trò chuyện (listview)
class Body extends StatefulWidget{
  final String uid_sender;
  final String uid_reciever;
  final String email; //to load avt

  const Body({Key? key, required this.uid_sender, required this.uid_reciever, required this.email}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final fireStore = FirebaseFirestore.instance;

  List list_messages = [];

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: DefaultPadding),
            child: StreamBuilder(
              stream: fireStore.collection('chats').doc(widget.uid_sender).collection(widget.uid_reciever).orderBy('time', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.hasData){
                  list_messages.clear();
                  var chat = snapshot.data!.docs;
                  chat.forEach((element) {
                    var data = element.data();
                    list_messages.add(data);
                  });

                  return ListView.builder(
                      reverse: true,
                      itemCount: list_messages.length,
                      itemBuilder: (context, index) =>
                          MessageContentWrap(message: list_messages[index], uid_sender: list_messages[index]['sender_uid'], uid: widget.uid_sender, email: widget.email,)
                  );
                }
                return LoadingScreen();
              }
            ),
          ),
        ),
        ChatInputField(uid_sender: widget.uid_sender, uid_reciever: widget.uid_reciever),
      ],
    );
  }
}

