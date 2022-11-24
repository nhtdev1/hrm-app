import 'package:cloud_firestore/cloud_firestore.dart';

class ChatState {}

class Loading extends ChatState {}

class Loaded extends ChatState{
  Stream<QuerySnapshot> snapshot;

  Loaded(this.snapshot);

  Loaded copyWith(Stream<QuerySnapshot> snapshot){
    return Loaded(snapshot);
  }
}