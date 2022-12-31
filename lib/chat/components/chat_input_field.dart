import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/chat/components/mess_structure.dart';
import 'package:xeplich/tools/const.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../tools/function.dart';

//khung nhập tin nhắn
class ChatInputField extends StatefulWidget {
  final String uid_sender;
  final String uid_reciever;

  ChatInputField({
    Key? key,
    required this.uid_sender, required this.uid_reciever,
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final fireStore = FirebaseFirestore.instance;
  String message = '';
  TextEditingController message_from_edittext = TextEditingController();

  @override
  Widget build(BuildContext context) {
    File file;
    String file_name;

    Future<void> pickImage() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'JPG', 'PNG', 'jpeg'],
      );

      if (result != null) { //sau khi chọn được ảnh
        file = File(result.files.single.path!);
        file_name = result.files.single.name;
        showToast("Đang gửi...", null);
        FirebaseStorage.instance.ref().child('messages/' + file_name).putFile(file).then((takeSnapshot) async {
          DocumentReference ref1 = fireStore.collection('chats').doc(widget.uid_sender).collection(widget.uid_reciever).doc();
          DocumentReference ref2 = fireStore.collection('chats').doc(widget.uid_reciever).collection(widget.uid_sender).doc();

          ref1.set({
            'content': await takeSnapshot.ref.getDownloadURL(),
            'sender_uid': widget.uid_sender,
            'time': DateTime.now()
          });
          ref2.set({
            'content': await takeSnapshot.ref.getDownloadURL(),
            'sender_uid': widget.uid_sender,
            'time': DateTime.now()
          });
          setState((){});
        }).catchError((e) => showToast("Lỗi mạng", null));
      } else {
        // User canceled the picker
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: DefaultPadding/2, horizontal: DefaultPadding),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 10),
                blurRadius: 20,
                color: Colors.grey.withOpacity(0.6)
            )
          ]
      ),
      child: SafeArea(
        child: Row(
          children: [
            if(widget.uid_sender == 'admin')
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.add, color: COLOR_PRIMARY_1),
                onPressed: () {
                  DateFormat dateFormat = DateFormat("HH:mm dd-MM-yyyy");
                  String message = 'Bạn chưa cập nhật thời gian biểu để sắp lịch cho tuần tới';
                  DocumentReference ref1 = fireStore.collection('chats').doc(
                      widget.uid_sender).collection(widget.uid_reciever).doc();
                  DocumentReference ref2 = fireStore.collection('chats').doc(
                      widget.uid_reciever).collection(widget.uid_sender).doc();

                  ref1.set({
                    'content': message,
                    'sender_uid': widget.uid_sender,
                    'time': DateTime.now()
                  });
                  ref2.set({
                    'content': message,
                    'sender_uid': widget.uid_sender,
                    'time': DateTime.now()
                  });
                },
              ),
            if(widget.uid_sender == 'admin')
              addHorizontalSpace(DefaultPadding / 2),
            InkWell(
              onTap: (){
                pickImage();
              },
                child: Icon(Icons.camera_alt, color: COLOR_PRIMARY_1,)
            ),
            addHorizontalSpace(DefaultPadding/2),
            Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: DefaultPadding /3, horizontal: DefaultPadding/2),
                  decoration: BoxDecoration(
                      color: COLOR_PRIMARY_3,
                      borderRadius: BorderRadius.all(Radius.circular(20.0))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Icon(Icons.sentiment_dissatisfied_outlined),
                      addHorizontalSpace(DefaultPadding/2),
                      Expanded(
                        child: TextField(
                          controller: message_from_edittext,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập văn bản',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: DefaultPadding/3),
                          ),
                          style: TextStyle(fontSize: FontSizeNormal),
                        ),
                      ),
                      addHorizontalSpace(DefaultPadding/2),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.send),
                        color: COLOR_PRIMARY_1,
                        onPressed: (){
                          message_from_edittext.text.trim().isEmpty ? null
                          : setState(() {
                            FocusScope.of(context).unfocus();
                            DocumentReference ref1 = fireStore.collection('chats').doc(widget.uid_sender).collection(widget.uid_reciever).doc();
                            DocumentReference ref2 = fireStore.collection('chats').doc(widget.uid_reciever).collection(widget.uid_sender).doc();

                            ref1.set({
                              'content': message_from_edittext.text.trim(),
                              'sender_uid': widget.uid_sender,
                              'time': DateTime.now()
                            });
                            ref2.set({
                              'content': message_from_edittext.text.trim(),
                              'sender_uid': widget.uid_sender,
                              'time': DateTime.now()
                            });

                            message_from_edittext.clear();
                          });
                        },
                      )
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}