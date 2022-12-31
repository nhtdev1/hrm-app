import 'package:cloud_firestore/cloud_firestore.dart';

class PostDoc {
  final String uid;
  final String content;
  final String email;
  final String image;
  final String name;
  final int createdAt;

  PostDoc(this.uid, this.content, this.email, this.image, this.name,
      this.createdAt);

  PostDoc.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] ?? "",
        content = json['content'] ?? "",
        email = json['email'] ?? "",
        image = json['image'] ?? "",
        name = json['name'] ?? "",
        createdAt = json['time'] != null
            ? (json['time'] as Timestamp).millisecondsSinceEpoch
            : 0;

  PostDoc.fromPref(Map<String, dynamic> json)
      : uid = json['uid'] ?? "",
        content = json['content'] ?? "",
        email = json['email'] ?? "",
        image = json['image'] ?? "",
        name = json['name'] ?? "",
        createdAt = json['time'] ?? 99999999999;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'content': content,
        'email': email,
        'image': image,
        'name': name,
        'time': createdAt,
      };
}
