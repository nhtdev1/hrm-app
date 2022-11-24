import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/staff/bloc/staff_event.dart';
import 'package:xeplich/staff/bloc/staff_state.dart';


class StaffBloc extends Bloc<StaffEvent, StaffState> {
  int count=0;
  Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance.collection('users').orderBy('no', descending: false).snapshots();

  Stream<QuerySnapshot> search_result_snapshot(String keyword) => FirebaseFirestore.instance
      .collection('users')
      .where('name', isEqualTo: keyword)
      .snapshots();

  StaffBloc() : super(Loaded(FirebaseFirestore.instance.collection('users').orderBy('no', descending: false).snapshots())) {
    on<Increment>((event, emit) => emit(Success(count++)));

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