import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/chat/components/mess_structure.dart';
import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../tools/function.dart';
import 'package:xeplich/homescreen/homescreen_staff.dart';

//khung nhập tin nhắn
class CommentInputField extends StatefulWidget {
  final String name;
  final String email;
  final String post_id;

  CommentInputField({
    Key? key, required this.email, required this.post_id, required this.name,
  }) : super(key: key);

  @override
  _CommentFieldState createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentInputField> {
  final fireStore = FirebaseFirestore.instance;
  String cmt = '';
  TextEditingController cmt_from_edittext = TextEditingController();

  // Future<String> get getName async {
  //   var snapshot = await fireStore.collection('users').where("email", isEqualTo: widget.email).get();
  //   return await snapshot.docs.elementAt(0).data()['name'];
  // }

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.camera_alt, color: COLOR_PRIMARY_1,),
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
                      Icon(Icons.sentiment_dissatisfied_outlined),
                      addHorizontalSpace(DefaultPadding/2),
                      Expanded(
                        child: TextField(
                          controller: cmt_from_edittext,
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
                        onPressed: () {
                          cmt_from_edittext.text.trim().isEmpty ? null
                              : setState(() {
                            FocusScope.of(context).unfocus();
                            DocumentReference ref = fireStore.collection('post').doc(widget.post_id).collection('comments').doc();

                            ref.set({
                              'contents': cmt_from_edittext.text.trim(),
                              'email': widget.email,
                              'name': widget.name,
                              'time': DateTime.now()
                            });

                            cmt_from_edittext.clear();
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