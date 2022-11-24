import 'package:cloud_firestore/cloud_firestore.dart';

class StaffState {}

class Loading extends StaffState {}

class Success extends StaffState {
  int count;

  Success(this.count);

  Success copyWith(int count){
    return Success(count);
  }
}

class Loaded extends StaffState{
  Stream<QuerySnapshot> snapshot;

  Loaded(this.snapshot);

  Loaded copyWith(Stream<QuerySnapshot> snapshot){
    return Loaded(snapshot);
  }
}

// class Loaded extends StaffState{
//   final Stream<QuerySnapshot> snapshot;
//
//   Loaded(this.snapshot);
//
//   Loaded copyWith(Stream<QuerySnapshot> snapshot){
//     return Loaded(snapshot ?? this.snapshot);
//   }
// }