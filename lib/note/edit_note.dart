import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditNote extends StatelessWidget {
  final String uid;

  const EditNote({Key? key, required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("HH:mm dd-MM-yyyy");
    TextStyle hint = TextStyle(fontSize: 20);
    TextEditingController note_title = TextEditingController();
    TextEditingController note_content = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Chỉnh Sửa Ghi Chú', style: titleAppBar),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY,
      ),
      body: Container(
        // margin: EdgeInsets.symmetric(vertical: DefaultPadding),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow:  [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.7),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: COLOR_PRIMARY,
              ),
              child: TextField(
                textAlign: TextAlign.center,
                style: hint,
                controller: note_title,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 20, top: 10),
                  hintText: 'Tiêu đề',
                  hintStyle: hint,
                  border: InputBorder.none,
                ),
              ),
            ),
            addVerticalSpace(DefaultPadding),
            Container(
              padding: EdgeInsets.symmetric(horizontal: DefaultPadding),
              child: TextField(
                style: hint,
                controller: note_content,
                // maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Nội dung',
                  hintStyle: hint,
                  border: InputBorder.none,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(note_title.text.trim() != ''){
            if(note_content.text.trim() != ''){
              //lưu
              FirebaseFirestore.instance.collection('users').doc(uid).collection('note').doc().set({
                'title': note_title.text.trim(),
                'content': note_content.text.trim(),
                'time': DateTime.now()
              }).whenComplete((){
                showToast('Đã lưu ghi chú', null);
                Navigator.pop(context);
              }).catchError((e){
                showToast('Lỗi', null);
              });
            }else showToast('Bạn chưa nhập nội dung ghi chú', null);
          }else{
            if(note_content.text.trim() != '')
              showToast('Bạn chưa nhập tiêu đề ghi chú', null);
            else null;
          }
        },
        child: Icon(Icons.save),
        backgroundColor: COLOR_PRIMARY_1,
      ),
    );
  }
}
