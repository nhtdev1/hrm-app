import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/staff/staff.dart';
import 'package:xeplich/tools/giai_thuat_sap_lich.dart';
import 'package:xeplich/tools/push_notification_service.dart';
import 'package:xeplich/tools/user_model.dart';
import 'package:xeplich/tools/const.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xeplich/tools/extension.dart';
import 'package:intl/intl.dart';
import '../tools/function.dart';

class AddMember extends StatefulWidget {
  final int count; //truyền biến đếm bao nhiêu thành viên

  const AddMember({Key? key, required this.count}) : super(key: key);

  @override
  _AddMemberState createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final fb = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;

  TextEditingController _id = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _tk = TextEditingController();
  TextEditingController _mk = TextEditingController();
  TextEditingController _ten = TextEditingController();
  TextEditingController _ngaySinh = TextEditingController();
  TextEditingController _ngayVaoLam = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _diaChi = TextEditingController();

  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();

  ThemeData get themeData => Theme.of(context);

  File? avatar;
  bool? hasAvatar;

  String createNewID(int count){ //hàm tạo ID
      if(count < 10)
        return '00$count';
      else if(count < 100)
        return '0$count';
      else return '$count';
  }

  Future addUser() async {
    String passMD5 = generateMd5(_mk.text.trim());
    await _auth.createUserWithEmailAndPassword(email: _email.text.trim(), password: passMD5)
      .then((value) async {
      await postDetailToFirestore().whenComplete((){
        returnAdmin();
        GiaiThuat().name_databaseToFile();
        GiaiThuat().lichRanh_old_databaseToFile();
        GiaiThuat().lichRanh_databaseToFile();
      });
    }).catchError((e){
      showToast(e.toString(), null);
    });
  }

  Future postDetailToFirestore() async{
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    //đặt các giá trị cho UserModel
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.no = _id.text; //số thứ tự, ID
    userModel.name = _ten.text;
    userModel.pass = generateMd5(_mk.text.trim());
    userModel.DOB = _ngaySinh.text;
    userModel.DOE = _ngayVaoLam.text;
    userModel.phone = _phone.text;
    userModel.address = _diaChi.text;
    userModel.lichRanh = '000000000000000000000';
    userModel.lichRanh_old = '000000000000000000000';

    //đặt id là uid để tiện truy cập
    await firebaseFirestore.collection('users').doc(userModel.uid).set(userModel.toMap());
    showToast('Đã thêm nhân viên ' + _ten.text, null);
  }

  void returnAdmin(){
    FirebaseFirestore.instance.collection('users').doc('admin').get().then((value){
      String pass_admin = value['pass'];
      _auth.signOut().whenComplete((){
        _auth.signInWithEmailAndPassword(email: 'admin@gmail.com', password: pass_admin);
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);

    _id.text = createNewID(widget.count); //tạo ID mới cố định
    _ngayVaoLam.text = formattedDate;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Nhân Viên', style: titleAppBar),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY,
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  addVerticalSpace(DefaultPadding),
                  InkWell(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'png', 'JPG', 'PNG', 'jpeg'],
                        ); //chọn ảnh

                        if (result != null) { //sau khi chọn được ảnh
                          avatar = File(result.files.single.path!);
                          hasAvatar = true;
                          setState(() {
                            
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 80.0,
                        backgroundColor: COLOR_PRIMARY_1,
                        child: hasAvatar != true ? Icon(
                          Icons.person,
                          size: 100.0,
                          color: Colors.white,
                        ) : null,
                        backgroundImage: hasAvatar != true ? null : Image.file(avatar!).image,
                      )),
                  addVerticalSpace(DefaultPadding*2),
                  Form1(size),
                  addVerticalSpace(DefaultPadding),
                  Form2(size),
                  addVerticalSpace(DefaultPadding),
                ],
              ),
            ),
          ),
          Positioned(
            child: FloatingActionButton(
              onPressed: (){
                if (_formKey1.currentState!.validate() &&
                    _formKey2.currentState!.validate()) {
                  FocusScope.of(context).unfocus(); //ẩn bàn phím
                  showLoadingScreen(context, themeData);
                  addUser().then((value){
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Staff()));
                    GiaiThuat().name_databaseToFile();
                  });

                  if (hasAvatar == true && avatar != null) {
                    FirebaseStorage.instance.ref().child('avt/' + _email.text + '.png').putFile(avatar!)
                        .catchError((e) {
                      showToast('Lỗi upload avatar', null);
                    });
                  }
                }else{
                  showToast('Lỗi nhập liệu\nVui lòng kiểm tra lại', null);
                }
                PushNotificationService().addNotification('Cảnh báo', 'Đã có sự thay đổi nhân sự, bạn nên kiểm tra lại lịch làm việc!');
              },
              backgroundColor: COLOR_PRIMARY_1,
              child: Icon(Icons.save),
            ),
            right: DefaultPadding,
            bottom: DefaultPadding,
          ),
        ],
      ),
    );
  }

  Container Form2(Size size) {
    return Container(
      width: size.width - paddingContainer * 2,
      margin: EdgeInsets.symmetric(horizontal: paddingContainer),
      padding: EdgeInsets.symmetric(
          vertical: DefaultPadding, horizontal: DefaultPadding),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Form(
                key: _formKey2,
                child: Column(
                  children: [
                    textFieldName(),
                    textFieldDOB(),
                    textFieldDOE(),
                    textFieldPhone(),
                    textFieldAddress(),
                    addVerticalSpace(DefaultPadding)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container Form1(Size size) {
    return Container(
      width: size.width - paddingContainer * 2,
      margin: EdgeInsets.symmetric(horizontal: paddingContainer),
      padding: EdgeInsets.symmetric(
          vertical: DefaultPadding, horizontal: DefaultPadding),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey1,
            child: Column(
              children: [
                textFieldID(),
                textFieldEmail(),
                textFieldPass(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget textFieldID() {
    return TextFormField(
      enabled: false,
      controller: _id,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'ID',
          labelStyle: labelText,
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.number,
      maxLength: 3,
      validator: (value) {
        if (value!.isValidID) {
          return 'ID bao gồm 3 ký tự số';
        } else
          return null;
      },
    );
  }

  Widget textFieldEmail() {
    return TextFormField(
      controller: _email,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Email',
          labelStyle: labelText,
          suffixText: '*',
          suffixStyle: requiredText
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.text,
      maxLength: 30,
      validator: (value) {
        if (value!.isNotEmpty)
          if(value.isValidEmail)
            return null;
          else return 'Email chưa đúng định dạng';
        else
          return 'Vui lòng nhập email';
      },
    );
  }

  Widget textFieldPass() {
    return TextFormField(
      controller: _mk,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Mật khẩu',
          labelStyle: labelText,
          suffixText: '*',
          suffixStyle: requiredText
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.text,
      maxLength: 8,
      validator: (value) {
        if (value!.isNotEmpty)
          if(value.isValidPassword)
            return null;
          else return 'Mật khẩu ít nhất 6 ký tự';
        else
          return 'Vui lòng nhập mật khẩu';
      },
    );
  }

  Widget textFieldName() {
    return TextFormField(
      controller: _ten,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Họ tên nhân viên',
          labelStyle: labelText,
          suffixText: '*',
          suffixStyle: requiredText
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isNotEmpty) {
          if (value.isValidName)
            return null;
          else
            return 'Vui lòng nhập đúng định dạng';
        } else
          return 'Vui lòng nhập tên';
      },
    );
  }

  Widget textFieldDOB() {
    return TextFormField(
      controller: _ngaySinh,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Ngày sinh',
          labelStyle: labelText,
          suffixText: '*',
          suffixStyle: requiredText
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value!.isNotEmpty) {
          if (value.isValidDate)
            return null;
          else
            return 'Vui lòng nhập đúng định dạng';
        } else
          return 'Vui lòng nhập ngày sinh';
      },
    );
  }

  // Widget textFieldGender() {
  //   return TextFormField(
  //     controller: _ngaySinh,
  //     decoration: InputDecoration(
  //       focusedBorder: UnderlineInputBorder(
  //         borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
  //       ),
  //       labelText: 'Ngày sinh',
  //       labelStyle: labelText,
  //     ),
  //     style: TextStyle(fontSize: FontSizeNormal),
  //     keyboardType: TextInputType.number,
  //     validator: (value) {
  //       if (value!.isNotEmpty) {
  //         if (value.isValidDate)
  //           return null;
  //         else
  //           return 'Vui lòng nhập đúng định dạng';
  //       } else
  //         return 'Vui lòng nhập ngày sinh';
  //     },
  //   );
  // }

  Widget textFieldDOE() {
    return TextFormField(
      controller: _ngayVaoLam,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
        ),
        labelText: 'Ngày vào làm',
        labelStyle: labelText,
        suffixText: '*',
        suffixStyle: requiredText
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value!.isValidDate)
          return null;
        else
          return 'Vui lòng nhập đúng định dạng';
      },
    );
  }

  Widget textFieldPhone() {
    return TextFormField(
      controller: _phone,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
        ),
        labelText: 'Số điện thoại',
        labelStyle: labelText,
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if(value!.isNotEmpty){
          if (value.isValidPhone)
            return null;
          else
            return 'Vui lòng nhập đúng định dạng';
        }
        else _phone.text == null;
      },
    );
  }

  Widget textFieldAddress() {
    return TextFormField(
      controller: _diaChi,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
        ),
        labelText: 'Địa chỉ',
        labelStyle: labelText,
      ),
      style: TextStyle(fontSize: FontSizeNormal),
      keyboardType: TextInputType.text,
      validator: (value){
        if(value!.isEmpty)
          _diaChi.text == null;
      },
    );
  }
}
