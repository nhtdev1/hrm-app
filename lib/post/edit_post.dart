import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditPost extends StatefulWidget {
  final String email;
  final String name;
  final String post_id;

  const EditPost(
      {Key? key, required this.name, required this.post_id, required this.email})
      : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  File? file;
  String file_name = '';

  Future<List<String>> getContentPost(String post_id) async {
    var value = await FirebaseFirestore.instance.collection('post').doc(post_id).get();
    return [await value['content'], await value['img']];
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("HH:mm dd-MM-yyyy");
    TextStyle hint = TextStyle(fontSize: 20);
    TextEditingController post_content = TextEditingController();
    String urlImg = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa Bài Viết', style: titleAppBar),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY,
      ),
      body: FutureBuilder<List<String>>(
          future: getContentPost(widget.post_id),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if(snapshot.hasData) {
              post_content.text = snapshot.data![0].toString();
              urlImg = snapshot.data![1].toString();

              return Container(
                margin: EdgeInsets.all(DefaultPadding),
                child: Column(
                  children: [
                    Row(
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
                    Container(
                      child: Column(
                        children: [
                          if(urlImg != '')
                          Column(
                            children: [
                              InkWell(
                                onTap: () async {
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
                                },
                                  child: file != null ? Image.file(file!) : Image.network(urlImg)),
                              addVerticalSpace(DefaultPadding)
                            ],
                          ),
                          TextField(
                            style: hint,
                            controller: post_content,
                            decoration: InputDecoration(
                              hintText: 'Bạn muốn viết gì?',
                              hintStyle: hint,
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            } return LoadingScreen();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // // Add your onPressed code here!
          // FocusScope.of(context).unfocus();
          // post_content.text.trim() == ''
          //     ? null
          //     :
          //     FirebaseFirestore.instance.collection('post').doc(widget.post_id).update({
          //       'content': post_content.text.trim()
          //     }).whenComplete(() {
          //         showToast('Đã chỉnh sửa', null);
          //         Navigator.pop(context);
          //       });
          (post_content.text.trim() == '' || file == null) ? null : updatePost(post_content.text.trim());
        },
        child: Icon(Icons.save),
        backgroundColor: COLOR_PRIMARY_1,
      ),
    );
  }

  updatePost(String post_content){
    if(file != null) {
      FirebaseStorage.instance.ref().child('post/' + file_name).putFile(file!).then((takeSnapshot) async {
        FirebaseFirestore.instance.collection('post').doc(widget.post_id).update({
          'content': post_content,
          'time': DateTime.now(),
          'img' : await takeSnapshot.ref.getDownloadURL()
        });
      }).catchError((e) {
        showToast('Không có kết nối mạng', null);
      });
      showToast('Bài viết đang được xử lý...', null);
      Navigator.pop(context);
    }else {
      FirebaseFirestore.instance.collection('post').doc().set({
        'content': post_content,
        'time': DateTime.now(),
      }).whenComplete(() {
        showToast('Bài viết đã chia sẻ', null);
        Navigator.pop(context);
      }).catchError((e) {
        showToast('Không có kết nối mạng', null);
      });
    }
  }
}
