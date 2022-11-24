import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewPost extends StatefulWidget {
  final String uid;
  final String email;
  final String name;

  const NewPost({Key? key, required this.uid, required this.email, required this.name})
      : super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  File? file;
  String file_name = '';

  @override
  Widget build(BuildContext context) {
    TextStyle hint = TextStyle(fontSize: 20);
    TextEditingController post_content = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Bài Viết', style: titleAppBar),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY,
        actions: [
          IconButton(
            icon: Icon(Icons.photo, color: Colors.white),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'png', 'JPG', 'PNG', 'jpeg'],
              );

              if (result != null) { //sau khi chọn được ảnh
                file = File(result.files.single.path!);
                file_name = widget.email + result.files.single.name;
                setState((){});
              } else {
                // User canceled the picker
              }
            }
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(DefaultPadding),
          child: Column(
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: DefaultPadding * 2.5,
                      height: DefaultPadding * 2.5,
                      child: cacheImgAvt(widget.email, 25),
                  ),
                  addHorizontalSpace(DefaultPadding / 2),
                  Text(
                    widget.name,
                    style: TextStyle(
                        fontSize: 18,
                        color: COLOR_PRIMARY_1,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              addVerticalSpace(DefaultPadding),
              if(file != null)
              Container(
                child: Column(
                  children: [
                    Image.file(file!),
                    addVerticalSpace(DefaultPadding)
                  ],
                )
              ),
              Container(
                child: TextField(
                  maxLines: null,
                  style: hint,
                  controller: post_content,
                  decoration: InputDecoration(
                    hintText: 'Bạn muốn viết gì?',
                    hintStyle: hint,
                    border: InputBorder.none,
                  ),
                ),
                // child: Text
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          (post_content.text.trim() == '' && file == null) ? null : post(post_content.text.trim());
        },
        child: Icon(Icons.navigation),
        backgroundColor: COLOR_PRIMARY_1,
      ),
    );
  }

  post(String post_content) {
    //Upload to Firebase
    if(file != null) {
      FirebaseStorage.instance.ref().child('post/' + file_name).putFile(file!).then((takeSnapshot) async {
        FirebaseFirestore.instance.collection('post').doc().set({
          'name': widget.name,
          'email': widget.email,
          'content': post_content,
          'time': DateTime.now(),
          'like': [],
          'img' : await takeSnapshot.ref.getDownloadURL()
        });
      }).catchError((e) {
        showToast('Không có kết nối mạng', null);
      });
      showToast('Bài viết đang được xử lý...', null);
      Navigator.pop(context);
    }else{
      FirebaseFirestore.instance.collection('post').doc().set({
        'name': widget.name,
        'email': widget.email,
        'content': post_content,
        'time': DateTime.now(),
        'like': [],
        'img' : ''
      }).catchError((e) {
        showToast('Không có kết nối mạng', null);
      });
      showToast('Đang xử lý...', null);
      Navigator.pop(context);
    }
  }
}
