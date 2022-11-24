import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewNote extends StatelessWidget {
  final String uid;
  final String? uid_note;
  final String? title_note;
  final String? content_note;

  const NewNote({Key? key, required this.uid, this.uid_note, this.title_note, this.content_note})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("HH:mm dd-MM-yyyy");
    TextStyle hint = TextStyle(fontSize: 20);
    TextEditingController note_title = TextEditingController();
    TextEditingController note_content = TextEditingController();

    if(uid_note != null){
      note_title.text = title_note!;
      note_content.text = content_note!;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: uid_note == null ? Text('Thêm Ghi Chú', style: titleAppBar)
        : Text('Chỉnh Sửa Ghi Chú', style: titleAppBar),
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
                style: hint.copyWith(color: COLOR_PRIMARY_1, fontWeight: FontWeight.w500),
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
          if(uid_note == null)
            save_note(context, note_title.text.trim(), note_content.text.trim());
          else
            update_note(context, note_title.text.trim(), note_content.text.trim(), uid_note!);
        },
        child: Icon(Icons.save),
        backgroundColor: COLOR_PRIMARY_1,
      ),
    );
  }

  void save_note(BuildContext context, String note_title, String note_content){
    if(note_title != ''){
      if(note_content != ''){
        //lưu
        FirebaseFirestore.instance.collection('users').doc(uid).collection('note').doc().set({
          'title': note_title,
          'content': note_content,
          'time': DateTime.now()
        }).whenComplete((){
          showToast('Đã lưu ghi chú', null);
          Navigator.pop(context);
        }).catchError((e){
          showToast('Lỗi', null);
        });
      }else showToast('Bạn chưa nhập nội dung ghi chú', null);
    }else{
      if(note_content != '')
        showToast('Bạn chưa nhập tiêu đề ghi chú', null);
      else null;
    }
  }

  void update_note(BuildContext context, String note_title, String note_content, String uid_note){
    if(note_title != ''){
      if(note_content != ''){
        //lưu
        FirebaseFirestore.instance.collection('users').doc(uid).collection('note').doc(uid_note).update({
          'title': note_title,
          'content': note_content,
          'time': DateTime.now()
        }).whenComplete((){
          showToast('Đã lưu thay đổi', null);
          Navigator.pop(context);
        }).catchError((e){
          showToast('Lỗi', null);
        });
      }else showToast('Bạn chưa nhập nội dung ghi chú', null);
    }else{
      if(note_content != '')
        showToast('Bạn chưa nhập tiêu đề ghi chú', null);
      else null;
    }
  }
}
