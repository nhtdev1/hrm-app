import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/post/bloc/like_event.dart';
import 'package:xeplich/post/bloc/like_state.dart';
import 'package:xeplich/post/edit_post.dart';
import 'package:xeplich/post/post_detail_expand.dart';
import 'package:xeplich/staff/bloc/staff_bloc.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xeplich/post/bloc/like_bloc.dart';
import 'package:flutter_bloc/src/bloc_builder.dart';

class PostDetails extends StatelessWidget{
  final String viewer_uid;
  final String? viewer_name;
  final String post_id;
  final dynamic post_data;
  final bool? isYourSelf;
  final String email;

  const PostDetails({Key? key, required this.post_data, this.isYourSelf, required this.post_id, required this.email, required this.viewer_uid, this.viewer_name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat("HH:mm dd-MM-yy");
    TextStyle contentStyle = TextStyle(fontSize: 20);

    var date = DateTime.fromMillisecondsSinceEpoch(post_data['time'].millisecondsSinceEpoch);
    String time = dateFormat.format(date);

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('post').doc(post_id).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
          if(snapshot.hasData) {
            dynamic data = snapshot.data!.data();
            int like_count = data!['like'].length;
            bool liked = false;
            String urlImg = data!['img'];
            for(int i=0; i<like_count; i++) {
              if (data!['like'][i].toString() == viewer_uid)
                liked = true;
            }

            return BlocProvider<LikeBloc>(
              create: (context) => liked == true
                  ? LikeBloc(Liked(like_count))
                  : LikeBloc(Unliked(like_count)),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: EdgeInsets.all(5.0),
                    padding: EdgeInsets.only(
                      top: DefaultPadding - 5.0,
                      right: DefaultPadding - 5.0,
                      left: DefaultPadding - 5.0,),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20.0))
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: DefaultPadding / 2),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(
                                  color: COLOR_GREY))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  cacheImgAvt(post_data['email'], 23),
                                  addHorizontalSpace(DefaultPadding / 2),
                                  Text(post_data['name'], style: TextStyle(fontSize: 17,
                                      color: COLOR_PRIMARY_1,
                                      fontWeight: FontWeight.w700),),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(time),
                                  if(isYourSelf == true) addHorizontalSpace(
                                      DefaultPadding / 2),
                                  if(isYourSelf == true) popup_menu(
                                      context, post_data['name']!, post_id)
                                ],
                              )
                            ],
                          ),
                        ),
                        addVerticalSpace(20),
                        if(urlImg != '')
                        Container(
                          child: Column(
                            children: [
                              Image.network(urlImg),
                              addVerticalSpace(DefaultPadding)
                            ],
                          )
                        ),
                        Container(
                          // color: COLOR_PRIMARY,
                          child: Text(post_data['content'], style: contentStyle),
                        ),
                        addVerticalSpace(DefaultPadding+5),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.favorite, size: 15,),
                                  BlocBuilder<LikeBloc, LikeState>(
                                      builder: (context, state){
                                        return Text('  ' + state.count.toString());
                                      }),
                                ],
                              ),
                              Row(
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: snapshot.data!.reference.collection('comments').snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot2) {
                                      if(snapshot2.hasData) {
                                        return Text(snapshot2.data!.size.toString());
                                      }return Text('0');
                                    }
                                  ),
                                  Text('  Bình luận')
                                ],
                              ),
                            ],
                          )
                        ),
                        addVerticalSpace(10),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(top: BorderSide(
                                  color: COLOR_GREY))
                          ),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BlocBuilder<LikeBloc, LikeState>(
                                builder: (context, state) {
                                  return Container(
                                      width: size.width * 0.4,
                                      child: Center(
                                        child: IconButton(icon: state is Unliked
                                            ? Icon(Icons.favorite_outline)
                                            : Icon(Icons.favorite,
                                            color: Colors.red),
                                          onPressed: () {
                                            if(liked == true) {
                                              BlocProvider.of<LikeBloc>(context).add(Decrement(like_count));
                                              like_count--;
                                              data!['like'].remove(viewer_uid);
                                              FirebaseFirestore.instance.collection('post').doc(post_id).update({
                                                'like': data!['like']
                                              });
                                            }else {
                                              BlocProvider.of<LikeBloc>(context).add(Increment(like_count));
                                              like_count++;
                                              data!['like'].add(viewer_uid);
                                              FirebaseFirestore.instance.collection('post').doc(post_id).update({
                                                'like': data!['like']
                                              });
                                            }
                                            liked = !liked;
                                          },
                                        ),
                                      )
                                  );
                                }
                              ),
                              Container(
                                color: COLOR_GREY,
                                width: 1,
                              ),
                              Container(
                                  width: size.width *0.4,
                                  child: Center(
                                    child: IconButton(icon: Icon(Icons.format_quote_outlined), 
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailExpand(like_count: like_count, viewer_uid: viewer_uid, post_id: post_id, email: email, name: viewer_name!)));
                                      },),
                                  )
                              )
                            ]
                          ),
                        )
                      ],
                    ),
                  ),
                  addVerticalSpace(DefaultPadding * 1.5)
                ],
              ),
            );
          } return Container();
        });
  }

  Widget popup_menu(BuildContext context, String name, String post_id) => PopupMenuButton<int>(
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 1,
        child: Text("Chỉnh sửa bài viết", style: TextStyle(fontSize: 16),),
      ),
      PopupMenuItem(
        value: 2,
        child: Text("Xóa bài viết", style: TextStyle(fontSize: 16)),
      ),
    ],
    // initialValue: 2,
    // onCanceled: () {
    //   print("You have canceled the menu.");
    // },
    onSelected: (value) {
      switch(value){
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditPost(name: name, post_id: post_id, email: email,)));
        break;
        case 2:
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                'Xác nhận',
                style: titleText,
              ),
              content: Text('Xóa bài viết?', style: TextStyle(fontSize: 18),),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Xóa');
                    FirebaseFirestore.instance.collection('post').doc(post_id).delete().whenComplete((){
                      showToast('Đã xóa bài viết', null);
                    });
                  },
                  child: const Text('Xóa', style: TextStyle(fontSize: 16, color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Hủy'),
                  child: const Text('Hủy', style: TextStyle(fontSize: 16, color: COLOR_PRIMARY_1)),
                ),
              ],
            )
        );
      }
    },
    iconSize: 20,
    child: SizedBox(
      width: 20,
      height: 30,
      child: Icon(Icons.more_vert),
    ),
  );
}

class Comment {
  final String uid_sender;
  final String time;
  final String content;

  Comment(this.uid_sender, this.time, this.content);
}