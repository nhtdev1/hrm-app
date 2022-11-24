import 'package:flutter/material.dart';

class MessStructure{
  String uid_reciever;
  String content;
  // String time;
  // String keySender; //người nhắn là ai
  // String anhdaidien;
  // bool isSender; //có phải người gửi hay ko

  MessStructure({
    required this.uid_reciever,
    required this.content,
    // required this.time,
    // required this.keySender,
    // required this.isSender
  });
}