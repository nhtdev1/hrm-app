import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/note/components/note_item.dart';
import 'package:xeplich/note/new_note.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:flutter/material.dart';

class Note extends StatefulWidget {
  final String uid;

  const Note({Key? key, required this.uid}) : super(key: key);

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text('Ghi Chú', style: titleAppBar),
        centerTitle: true,
        iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
        backgroundColor: COLOR_PRIMARY,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .collection('note')
              .orderBy("time", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var value = snapshot.data!.docs;

              return Container(
                padding: EdgeInsets.only(top: DefaultPadding),
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return NoteItem(title: value[index]['title'], content: value[index]['content'], uid: widget.uid, uid_note: value[index].id,);
                    }),
              );
            }
            return LoadingScreen();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewNote(uid: widget.uid)));
        },
        child: Icon(Icons.add),
        backgroundColor: COLOR_PRIMARY_1,
      ),
    );
  }
}
