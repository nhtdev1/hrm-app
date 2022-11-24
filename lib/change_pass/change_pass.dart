import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/login/components/rounded_input.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xeplich/tools/extension.dart';

class ChangePassword extends StatefulWidget{
  final String uid;

  const ChangePassword({Key? key, required this.uid}) : super(key: key);
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController currentPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  bool? isLoading;
  bool ready = false;

  void validateForm(){
    if(currentPass.text.trim().isNotEmpty && newPass.text.trim().isNotEmpty){
      setState(() {
        ready = true;
      });
      if(!newPass.text.trim().isValidPassword) {
        showToast('Mật khẩu mới chưa đúng định dạng', COLOR_PRIMARY_3);
        setState(() {
          ready = false;
        });
      }
    }else
      setState(() {
        ready = false;
      });
  }

  Future _changePassword(String currentPassword, String newPassword) async {
    String currentPasswordMD5 = generateMd5(currentPassword);
    String newPasswordMD5 = generateMd5(newPassword);

    final user = await FirebaseAuth.instance.currentUser;
    if(user != null){
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPasswordMD5);

      user.reauthenticateWithCredential(cred).then((value) {
        user.updatePassword(newPasswordMD5).then((_) {
          //Success, do something
          firestore.collection('users').doc(widget.uid).update({
            'pass': newPasswordMD5
          });
          showToast('Cập nhật mật khẩu thành công', COLOR_PRIMARY_3);
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        }).catchError((error) {
          //Error, show something
          setState(() {
            isLoading = false;
          });
          showToast('Lỗi\nKhông thể thay đổi mật khẩu', COLOR_PRIMARY_3);
        });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        showToast('Mật khẩu cũ nhập chưa chính xác', COLOR_PRIMARY_3);
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đổi mật khẩu', style: titleAppBar),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY_1,
      ),
      body: Container(
        color: COLOR_PRIMARY_1,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addVerticalSpace(DefaultPadding),
                CircleAvatar(
                  radius: 80.0,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.lock,
                    size: 100.0,
                    color: COLOR_PRIMARY_1,
                  ),
                ),
                addVerticalSpace(DefaultPadding*3),
                Rounded_Input(hintText: 'Mật khẩu cũ', textController: currentPass,),
                addVerticalSpace(DefaultPadding),
                Rounded_Input(hintText: 'Mật khẩu mới', textController: newPass),
                addVerticalSpace(DefaultPadding),
                InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    validateForm();
                    if(ready == true) {
                      isLoading = true;
                      _changePassword(currentPass.text.trim(), newPass.text.trim());
                      // FirebaseFirestore.instance.collection('users').doc('admin').update({
                      //   'pass': newPass.text
                      // });
                    }else showToast('Bạn chưa nhập gì mà', COLOR_PRIMARY_3);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.8 * 0.15,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: COLOR_CONTRAST,
                    ),
                    child: Center(
                        child: isLoading != true ? Text('CẬP NHẬT', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))
                            : SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white))
                    ),
                  ),
                ),
                addVerticalSpace(DefaultPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}