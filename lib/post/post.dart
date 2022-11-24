import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/post/components/my_post.dart';
import 'package:xeplich/post/components/post_details.dart';
import 'package:xeplich/post/new_post.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  final String uid;
  final String email;

  const Post({Key? key, required this.uid, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = '', email = '';

    void myPost(String value){
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyPost(uid: uid)));
    }

    return Scaffold(
      appBar: AppBar(
          title: Text('Bài Viết', style: titleAppBar),
          centerTitle: true,
          backgroundColor: COLOR_PRIMARY,
          actions: <Widget>[
            PopupMenuButton<String>(
                // padding: EdgeInsets.zero,
                onSelected: myPost,
                itemBuilder: (BuildContext context) {
              return {'Bài viết của bạn'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: TextStyle(fontSize: 18),),
                );
              }).toList();
            })
          ]),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              var value = snapshot.data!.data() as Map<String, dynamic>;
              name = value['name'];
              email = value['email'];

              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('post')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      var value = snapshot.data!.docs;

                      return Container(
                        padding: EdgeInsets.only(top: DefaultPadding),
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              return PostDetails(
                                viewer_uid: uid,
                                post_id: value[index].id,
                                post_data: value[index],
                                email: email,
                                viewer_name: name,
                              );
                            }),
                      );
                    }
                    return LoadingScreen();
                  });
            }
            return LoadingScreen();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          name == ''
              ? null
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewPost(
                            uid: uid,
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
