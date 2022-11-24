import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget{
  final String name;
  final String email;

  UserPage({
    Key? key,
    required this.name,
    required this.email
  }) :super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<String> getURL(String email) async {
    return await FirebaseStorage.instance.ref()
        .child('avt/' + email + '.png').getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY,
        actions: [
          if(widget.name == 'ADMIN')
            IconButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'png', 'JPG', 'PNG', 'jpeg'],
                  );

                  if (result != null) { //sau khi chọn được ảnh
                    File file = File(result.files.single.path!);
                    showToast('Đang xử lý...', null);
                    //Upload to Firebase
                    await FirebaseStorage.instance.ref().child('avt/' + widget.email + '.png').putFile(file)
                        .then((_){
                      setState(() {

                      });
                    }).catchError((e){
                      showToast('Không có kết nối mạng', null);
                    });
                  } else {
                    // User canceled the picker
                  }
                },
                icon: Icon(Icons.camera_enhance_rounded)
            )
        ],
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: getURL(widget.email),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              return CachedNetworkImage(
                imageUrl: snapshot.data!,
                // fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator(color: COLOR_PRIMARY_1,)),
                errorWidget: (context, url, error) => Icon(Icons.error),
              );
            } return Image(image: AssetImage('assets/default_avatar.jpg'));
          }
        ),
      ),
    );
  }
}