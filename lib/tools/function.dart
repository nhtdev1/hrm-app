import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'const.dart';
import 'file_storage.dart';

Widget addVerticalSpace(double height){
  return SizedBox(
    height: height,
  );
}

Widget addHorizontalSpace(double width){
  return SizedBox(
    width: width,
  );
}

Widget addLine(double margin){
  return Container(
    margin: EdgeInsets.symmetric(horizontal: margin),
    height: 0.7,
    color: Colors.grey,
  );
}

// Future<String> getURL(String email) async {
//   return await FirebaseStorage.instance.ref()
//       .child('avt/' + email + '.png').getDownloadURL();
// }
//
// Future<NetworkImage> getImg(String email) async{
//   return NetworkImage(await getURL(email));
// }

Widget cacheImgAvt(String email, double radius){
  Future<String> getURL(String email) async {
    return await FirebaseStorage.instance.ref()
        .child('avt/' + email + '.png').getDownloadURL();
  }

  return FutureBuilder<String>(
    future: getURL(email),
    builder: (context, snapshot) {
      if(snapshot.hasData) {
        return CircleAvatar(
          // child: CachedNetworkImage(
          //   imageUrl: snapshot.data!,
          //   fit: BoxFit.cover,
          //   placeholder: (context, url) =>
          //       Center(child: CircularProgressIndicator(color: COLOR_PRIMARY_1,)),
          //   errorWidget: (context, url, error) => Icon(Icons.error),
          // ),
          backgroundImage: CachedNetworkImageProvider(snapshot.data!),
          backgroundColor: COLOR_PRIMARY_1,
          radius: radius,
        );
      }
      return CircleAvatar(backgroundImage: AssetImage('assets/default_avatar.jpg'), radius: radius,);
    }
  );
}


void showToast(String msg, Color? color) {
  Fluttertoast.showToast(
      msg: msg,
      fontSize: 16.0,
      backgroundColor: color == null ? COLOR_PRIMARY_1 : color,
      textColor: color != null ? COLOR_PRIMARY_1 : Colors.white
  );
}

void showLoadingScreen(BuildContext context, ThemeData themeData){
  showDialog(
    context: context,
    builder: (BuildContext context){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white,),
          addVerticalSpace(DefaultPadding),
          Text('Chờ chút ...', style: themeData.textTheme.headline3!.copyWith(color: Colors.white))
        ],
      );
    }
  );
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

// Future<void> loadNameToFile() async {
//   FileStorage().cleanFile('name');
//   QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore.instance.collection('users').get();
//
//   users.docs.forEach((doc) {
//     if(doc['no'] != '000') {
//       String name = doc['name'];
//       FileStorage().writeFile(
//           name.substring(name.lastIndexOf(" ") + 1), 'name');
//     }
//   });
// }