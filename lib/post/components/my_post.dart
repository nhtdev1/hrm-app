import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/post/components/post_details.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:flutter/material.dart';

import '../new_post.dart';

class MyPost extends StatefulWidget{
  final String uid;


  const MyPost({Key? key, required this.uid}) : super(key: key);

  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  String email = '';
  String name = '';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: Text('Bài Viết Của Bạn', style: titleAppBar),
          centerTitle: true,
          backgroundColor: COLOR_PRIMARY,
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              var value = snapshot.data!.data() as Map<String, dynamic>;
              email = value['email'];
              name = value['name'];

              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('post').where('email', isEqualTo: email)
                      // .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      var value = snapshot.data!.docs;
                      // print(value[0]['time']);

                      return Container(
                        padding: EdgeInsets.only(top: DefaultPadding),
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              print(value[index].id);
                              print(value[index]['time']);
                              return PostDetails(
                                viewer_uid: widget.uid,
                                post_id: value[index].id,
                                post_data: value[index],
                                isYourSelf: true,
                                email: email,
                              );
                              // return Text('oo');
                            }),
                      );
                    }
                    return Container(
                      child: Center(child: Text('Bạn chưa có bài viết nào')),
                    );
                  });
            }
            return LoadingScreen();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          email == ''
              ? null
              : Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewPost(
                    uid: widget.uid,
                    email: email,
                    name: name,
                  )));
        },
        child: Icon(Icons.add_to_photos),
        backgroundColor: COLOR_PRIMARY_1,
      ),
    );
  }
}