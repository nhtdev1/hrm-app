import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//khung hiển thị tin nhắn
class MessageContentWrap extends StatefulWidget {
  final dynamic message;
  final String uid_sender;
  final String uid; //uid of current user
  final String email; //to load avt

  const MessageContentWrap({
    Key? key,
    required this.message,
    required this.uid_sender,
    required this.uid,
    required this.email,
  }) : super(key: key);

  @override
  _MessageContentState createState() => _MessageContentState();
}

class _MessageContentState extends State<MessageContentWrap> {
  final String urlAvt = 'https://ss-images.saostar.vn/pc/1605234579397/z2174715918193_7a8c2d1a36fa6b98074de65420dcb7dd(1).jpg';
  bool isShowTime = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat("HH:mm  dd-MM-yy");
    var date = DateTime.fromMillisecondsSinceEpoch(widget.message['time'].millisecondsSinceEpoch);
    String time = dateFormat.format(date);

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: (){
        setState(() {
          isShowTime = !isShowTime;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: DefaultPadding/2),
        child: Column(
          children: [
            if(isShowTime == true) ... [
              Center(child: Text(time))
            ],
            Row(
              mainAxisAlignment: widget.uid_sender == widget.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if(widget.uid_sender != widget.uid) ... [
                  cacheImgAvt(widget.email, 12),
                  addHorizontalSpace(DefaultPadding/3)
                ],
                Container(
                  constraints: BoxConstraints(
                      maxWidth: size.width/2
                  ),
                  margin: EdgeInsets.only(top: DefaultPadding/4),
                  padding: EdgeInsets.symmetric(vertical: DefaultPadding/2.5, horizontal: DefaultPadding),
                  decoration: BoxDecoration(
                      color: widget.uid_sender == widget.uid ? COLOR_PRIMARY : COLOR_PRIMARY_1,
                      borderRadius: BorderRadius.all(Radius.circular(20.0))
                  ),
                  child: widget.message['content'].contains("https://firebasestorage.googleapis.com")
                  ? Image.network(widget.message['content'])
                  : Text(widget.message['content'], style: TextStyle(
                      color: widget.uid_sender == widget.uid ?  COLOR_PRIMARY_1 : Colors.white,
                      fontSize: FontSizeNormal
                  ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}