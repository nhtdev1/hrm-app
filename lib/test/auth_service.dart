import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthService with ChangeNotifier{
  bool _isLoading = false;
  late String _errorMess;
  bool get isLoading => _isLoading;
  String get errorMess => _errorMess;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future register(String email, String pass) async {
    setLoading(true);
    try{
      UserCredential authResult = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: pass);
      User? user = authResult.user;
      setLoading(false);
      return user;
    }on SocketException{
      setLoading(false);
      setMess('Lỗi mạng');
    }
    catch(e){
      setMess(e);
    }
    notifyListeners();
  }

  Future login(String email, String pass) async {
    setLoading(true);
    try{
      UserCredential authResult = await firebaseAuth.signInWithEmailAndPassword(email: email, password: pass);
      // User? user = authResult.user;
      setLoading(false);
      // return user;
    }on SocketException{
      setLoading(false);
      setMess('Lỗi mạng');
    }
    catch(e){
      setMess(e.toString());
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  void setLoading(val){
    _isLoading = val;
    notifyListeners();
  }

  void setMess(message){
    _errorMess = message;
    notifyListeners();
  }

  Stream<User> get user =>
      firebaseAuth.authStateChanges().map((event) => event!);

}