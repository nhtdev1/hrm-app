import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/post/components/comment_input_field.dart';
import 'package:xeplich/staff/component/loading_default.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class PostDetailExpand extends StatelessWidget{
  final String post_id;
  final String viewer_uid;
  final int like_count;
  final String name;
  final String email;

  const PostDetailExpand({Key? key, required this.like_count, required this.viewer_uid, required this.post_id, required this.email, required this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('post').doc(post_id).collection('comments').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.hasData) {
            int cmt_count = snapshot.data!.size;
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),

              child: Column(
                children: [
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(
                      top: DefaultPadding*2,
                      right: DefaultPadding,
                      left: DefaultPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.red,),
                            Text('  ' + like_count.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Text(cmt_count.toString()),
                            Text('  Bình luận')
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                            color: COLOR_GREY))
                    ),
                  ),
                  // addVerticalSpace(DefaultPadding),
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: DefaultPadding,
                            right: DefaultPadding
                        ),
                        child: ListView.builder(
                          itemCount: cmt_count,
                          itemBuilder: (context, index) => buildItemComment(size, snapshot.data!.docs[index]),
                        ),
                      )
                  ),
                  CommentInputField(email: email, post_id: post_id, name: name,)
                ],
              ),
            );
          }return LoadingScreen();
        }
      ),
    );
  }

  Container buildItemComment(Size size, dynamic data) {
    DateFormat dateFormat = DateFormat("HH:mm  dd-MM-yy");
    var date = DateTime.fromMillisecondsSinceEpoch(data['time'].millisecondsSinceEpoch);
    String time = dateFormat.format(date);

    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cacheImgAvt(data['email'], 25.0),
                SizedBox(
                  width: size.width - 50 - DefaultPadding *2 - DefaultPadding/2,
                    child: Container(
                      padding: EdgeInsets.all(DefaultPadding/2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['name'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: FontSizeNormal),),
                          addVerticalSpace(8),
                          Text(data['contents'], style: TextStyle(fontSize: FontSizeNormal)),
                          addVerticalSpace(8),
                          Text(time, style: TextStyle(color: Colors.white),)
                        ],
                      ),
                    )
                )
              ],
            ),
          );
  }
}