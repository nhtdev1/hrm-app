import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  int count=0;
  Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance.collection('users').orderBy('no', descending: false).snapshots();

  Stream<QuerySnapshot> search_result_snapshot(String keyword) => FirebaseFirestore.instance
      .collection('users')
      .where('name', isEqualTo: keyword)
      .snapshots();

  ChatBloc() : super(Loaded(FirebaseFirestore.instance.collection('users').orderBy('no', descending: false).snapshots())) {
    on<UpdateData>((event, emit) {
      if(event.keyword == '')
        return emit(Loaded(snapshot));
      else
      return emit(Loaded(search_result_snapshot(event.keyword)));
    });
  }
}

extension ArrayContain on Query{

}