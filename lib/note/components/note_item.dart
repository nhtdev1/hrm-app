import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/note/new_note.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:flutter/material.dart';

class NoteItem extends StatefulWidget{
  final String title;
  final String content;
  final String uid;
  final String uid_note;

  const NoteItem({Key? key, required this.title, required this.content, required this.uid, required this.uid_note}) : super(key: key);

  @override
  _NoteItemState createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  TextStyle titleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: COLOR_PRIMARY_1);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewNote(uid: widget.uid, uid_note: widget.uid_note, title_note: widget.title, content_note: widget.content,)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: DefaultPadding/2, horizontal: 5),
        padding: EdgeInsets.all(DefaultPadding),
        decoration: BoxDecoration(
          color: COLOR_PRIMARY.withOpacity(0.4),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.only(bottom: DefaultPadding/2),
                    child: Text(widget.title, style: titleStyle,)
                ),
                popup_menu(context, widget.uid, widget.uid_note),
              ],
            ),
            addLine(0),
            Container(
              // color: COLOR_PRIMARY,
              padding: EdgeInsets.symmetric(vertical: DefaultPadding/2),
              child: Text(widget.content, style: TextStyle(fontSize: 17),),
            ),
          ],
        ),
      ),
    );
  }

  Widget popup_menu(BuildContext context, String uid, String uid_note) => PopupMenuButton<int>(
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 1,
        child: Text("Xóa ghi chú", style: TextStyle(fontSize: 16)),
      ),
    ],
    // initialValue: 2,
    // onCanceled: () {
    //   print("You have canceled the menu.");
    // },
    onSelected: (value) {
      switch(value){
        case 1:
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(
                  'Xác nhận',
                  style: titleText,
                ),
                content: Text('Xóa ghi chú?', style: TextStyle(fontSize: 18),),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Xóa');
                      FirebaseFirestore.instance.collection('users').doc(uid).collection('note').doc(uid_note).delete().whenComplete((){
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