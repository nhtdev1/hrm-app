import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/chat/chat_content.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/file_storage.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/homescreen/components/user_page.dart';
import 'package:xeplich/tools/giai_thuat_sap_lich.dart';
import 'package:xeplich/tools/loading_screen.dart';
import 'package:xeplich/tools/push_notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xeplich/tools/extension.dart';

class MemberDetails extends StatefulWidget {
  final String uid;
  final bool? isAdmin;

  const MemberDetails({Key? key, required this.uid, this.isAdmin}) : super(key: key);

  @override
  _MemberDetailsState createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  final firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? info_data;
  bool _disState = false; //biến trạng thái TextField
  Icon _iconSave_Edit = Icon(Icons.edit);

  TextEditingController _id = TextEditingController(text: '999');
  TextEditingController _email = TextEditingController();
  TextEditingController _mk = TextEditingController();
  TextEditingController _ten = TextEditingController();
  TextEditingController _ngaySinh = TextEditingController();
  TextEditingController _ngayVaoLam = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _diaChi = TextEditingController();

  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();

  ThemeData get themeData => Theme.of(context); //lấy themeData
  TextStyle info_user = TextStyle(fontSize: FontSizeNormal, fontWeight: FontWeight.w700);

  Future updateData(String uid) async {
    await firestore.collection('users').doc(uid).update({
      'name': _ten.text,
      'DOB': _ngaySinh.text,
      'DOE': _ngayVaoLam.text,
      'phone': _phone.text,
      'address': _diaChi.text
    });
  }

  Future deleteMember(String ID) async {//tham số vào là ID (no) của nhân viên đã bị xóa
    String lastID = '';
    //kéo nhân viên cuối cùng vào chỗ nhân viên sẽ xóa
    await firestore.collection('users').get().then((list_users) async {
      //lấy ID nhân viên cuối cùng trong DS
      if (list_users.size - 1 < 10)
        lastID = '00'+ (list_users.size - 1).toString();
      else if (list_users.size -1 < 100)
        lastID = '0' + (list_users.size - 1).toString();
      else
        lastID = (list_users.size - 1).toString();

      print(lastID);//đúng 006

      for(int i=0; i<list_users.size; i++){
        print(list_users.docs.elementAt(i).data()['no']);
        if(list_users.docs.elementAt(i).data()['no'] == lastID){
          deleteAllData().then((value){
            GiaiThuat().name_databaseToFile();
            GiaiThuat().lichRanh_databaseToFile();
            GiaiThuat().lichRanh_old_databaseToFile();
          });//chỉ xoá, không update no
        }else {
          QuerySnapshot<Map<String, dynamic>> lastUser = await firestore.collection('users').where("no", isEqualTo: lastID).get();
          String uid_last_user = lastUser.docs.elementAt(0).id;
          //update no
          firestore.collection('users').doc(uid_last_user).update({
            'no': ID
          }).then((value) async {
            deleteAllData().then((value){
              GiaiThuat().name_databaseToFile();
              GiaiThuat().lichRanh_databaseToFile();
              GiaiThuat().lichRanh_old_databaseToFile();
            });
          });
        }
        break;
      }
    });
  }

  Future deleteAccFromFirebaseAuth(String email, String pass) async {
    firestore.collection('users').doc('admin').get().then((value) async {
      String pass_admin = value['pass']; //lấy pass admin
      //1. đăng xuất admin
      _auth.signOut();
      //2. đăng nhập tài khoản muốn xóa
      await _auth.signInWithEmailAndPassword(email: email, password: pass).then((value) async {
        //3. xóa tài khoản
        await _auth.currentUser!.delete();
      });
      //4. quay trở lại tài khoản admin
      await _auth.signInWithEmailAndPassword(email: 'admin@gmail.com', password: pass_admin);
    });
  }

  void deleteAvt(String email){
    FirebaseStorage.instance.ref().child('avt/' + email + '.png').delete().catchError((e){
      print('no avt to delete');
    });
  }

  void deletePost(String email) {
    var post_query = firestore.collection("post").where("email", isEqualTo: email);
    post_query.get().then((querySnapshot){
      querySnapshot.docs.forEach((element) {
        firestore.collection('post').doc(element.id).delete();
      });
    });
  }

  //chưa xoá được
  Future<void> deleteChat(String uid) async {
    //xoá tin nhắn chính
    firestore.collection('chats').doc(uid).delete().whenComplete((){
      //xoá tin nhắn phụ - người nhận
      var chat_query = firestore.collection("chats").doc().snapshots();
      chat_query.forEach((sender) {
        sender.reference.collection(uid).get().then((querySnapshot){
          //nếu tồn tại tin nhắn
          if(querySnapshot.size != 0) {
            querySnapshot.docs.forEach((message) {
              //xoá từng tin nhắn
              sender.reference.collection(uid).doc(message.id).delete();
            });
          }
        });
      });
    });
  }

  void deleteNote(String uid){
    firestore.collection('users').doc(uid).collection('note').get().then((value){
      value.docs.forEach((element) {
        print(element.id);
        firestore.collection('users').doc(uid).collection('note').doc(element.id).delete();
      });
    });
  }

  Future<void> deleteAllData()async {
    //xóa acc ở fire auth
    await deleteAccFromFirebaseAuth(_email.text.trim(), _mk.text.trim());
    //xóa dữ liệu ở firestore
    await firestore.collection('users').doc(widget.uid).delete();
    //xóa avatar
    deleteAvt(_email.text.trim());
    //xóa post liên quan
    deletePost(_email.text.trim()); //đổi thành tham số uid tránh sai sót đổi tên
    //xoá chat
    deleteChat(widget.uid);
    //xoá note
    deleteNote(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    DocumentReference user = firestore.collection('users').doc(widget.uid);

    String urlAvt =
        'https://ss-images.saostar.vn/pc/1605234579397/z2174715918193_7a8c2d1a36fa6b98074de65420dcb7dd(1).jpg';
    TextStyle title = TextStyle(
        color: COLOR_PRIMARY_1,
        fontSize: themeData.textTheme.headline4!.fontSize!.toDouble() + 1,
        fontWeight: FontWeight.w600);

    void handleClick(String value) {
      switch (value) {
        case 'Logout':
          break;
        case 'Settings':
          break;
      }
    }

    // TODO: implement build
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Thông Tin Nhân Viên', style: titleAppBar),
          centerTitle: true,
          iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
          backgroundColor: COLOR_PRIMARY,
          actions: [
            // buildPopupMenuButton(handleClick, themeData),
            if(widget.isAdmin == true)
            IconButton(
                onPressed: (){
                  if(info_data != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          ChatContent(info_data: info_data, sender_uid: 'admin')),
                    );
                  }
                },
                icon: Icon(Icons.message_outlined))
          ],
        ),
        body: FutureBuilder(
            future: user.get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if(snapshot.hasData){
                var values = snapshot.data!.data() as Map<String, dynamic>;

                info_data = values;//truyền dữ liệu cho icon button message

                _id.text = values['no'];
                _email.text = values['email'];
                _mk.text = values['pass'];
                _ten.text = values['name'];
                _ngaySinh.text = values['DOB'];
                _ngayVaoLam.text = values['DOE'];
                values['phone'] == null ? _phone.text = '' : _phone.text = values['phone'];
                values['address'] == null ? _diaChi.text = '' : _diaChi.text = values['address'];

                return Stack(children: [
                  Container(
                    height: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          addVerticalSpace(DefaultPadding),
                          InkResponse(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserPage(
                                            name: _ten.text.trim(),
                                            email: _email.text,)));
                              },
                              child: CircleAvatar(
                                radius: 85,
                                backgroundColor: COLOR_PRIMARY,
                                child: Stack(
                                  children: [
                                    cacheImgAvt(_email.text.trim(), 80),
                                    if(widget.isAdmin != true)
                                    Positioned(
                                      bottom: 5,
                                      right: 5,
                                      child: InkWell(
                                        onTap: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['jpg', 'png', 'JPG', 'PNG', 'jpeg'],
                                          );

                                          if (result != null) { //sau khi chọn được ảnh
                                            File file = File(result.files.single.path!);
                                            // String path = await FileStorage().localPath;
                                            showToast('Đang xử lý...', null);
                                            //Upload to Firebase
                                            await FirebaseStorage.instance.ref().child('avt/' + _email.text + '.png').putFile(file)
                                            .then((_){
                                              setState(() {

                                              });
                                            }).catchError((e){
                                              showToast('Không có kết nối mạng', null);
                                            });

                                            // TaskSnapshot snapshot = await FirebaseStorage.instance.ref()
                                            //     .child('avt/' + _email.text + '.png')
                                            //     .putFile(file).whenComplete(() async {
                                            //   await FileStorage().deleteFile('images/avt/' + _email.text + '.png');
                                            //   await file.copy('$path/images/avt/' + _email.text + '.png').whenComplete((){
                                            //     // File avt = File('$path/images/avt/' + _email.text + '.png');
                                            //     // TaskSnapshot snapshot = await FirebaseStorage.instance.ref()
                                            //     //     .child('avt/' + _email.text + '.png').writeToFile(avt);
                                            //     // setState(() {
                                            //     //
                                            //     // });
                                            //   }); //copy file ảnh được chọn vào một file khác trong bộ nhớ ưd
                                            //
                                            // }).catchError((e){
                                            //   showToast('Không có kết nối mạng', null);
                                            // });
                                          } else {
                                            // User canceled the picker
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: COLOR_PRIMARY_1,
                                            child: Icon(Icons.camera_enhance_rounded, size: 18, color: Colors.white,),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              )
                          ),
                          addVerticalSpace(DefaultPadding/1.5),
                          Container(
                            child: Center(
                              child: Text(values['name'], style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: COLOR_PRIMARY_1),),
                            ),
                          ),
                          addVerticalSpace(DefaultPadding * 2),
                          Form1(size),
                          addVerticalSpace(DefaultPadding),
                          Form2(size),
                          addVerticalSpace(DefaultPadding),
                        ],
                      ),
                    ),
                  ),
                  if(widget.isAdmin == true)
                    Positioned(
                      child: buttonDelete(),
                      right: DefaultPadding,
                      bottom: DefaultPadding,
                    ),
                  Positioned(
                    child: buttonEdit(),
                    right: widget.isAdmin == true ? DefaultPadding * 5 : DefaultPadding,
                    bottom: DefaultPadding,
                  ),
                ]);
              }
              return LoadingScreen();
            }));
  }

  // PopupMenuButton<String> buildPopupMenuButton(
  //     void handleClick(String value), ThemeData themeData) {
  //   return PopupMenuButton<String>(
  //     onSelected: handleClick,
  //     itemBuilder: (BuildContext context) {
  //       return {'Nhắn tin', 'Cảnh cáo'}.map((String choice) {
  //         return PopupMenuItem<String>(
  //           value: choice,
  //           child: Text(
  //             choice,
  //             style: themeData.textTheme.headline4!
  //                 .copyWith(fontWeight: FontWeight.w400),
  //           ),
  //         );
  //       }).toList();
  //     },
  //   );
  // }

  FloatingActionButton buttonDelete() {
    return FloatingActionButton(
      heroTag: null,
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(
              'Xác nhận',
              style: titleText,
            ),
            content: Text('Bạn có chắc muốn xóa ' + _ten.text + ' không?'),
            actions: <Widget>[
              TextButton(
                onPressed: (){
                  Navigator.pop(context, 'OK');
                  showLoadingScreen(context, themeData);
                  deleteMember(_id.text).then((value){
                    showToast('Đã xóa nhân viên', null);
                    Navigator.pop(this.context);
                    Navigator.pop(this.context);
                    GiaiThuat().name_databaseToFile();
                  });
                  PushNotificationService().addNotification('Cảnh báo', 'Đã có sự thay đổi nhân sự, bạn nên kiểm tra lại lịch làm việc!');
                },
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'Hủy'),
                child: const Text('Hủy'),
              ),
            ],
          ),
        );
      },
      backgroundColor: COLOR_PRIMARY_1,
      child: Icon(Icons.delete),
    );
  }

  FloatingActionButton buttonEdit() {
    return FloatingActionButton(
      heroTag: null,
      onPressed: () {
        if (_disState == false) {
          //nếu textfield đang ko cho nhập
          setState(() {
            _disState = !_disState; //chuyển thành cho nhập
            _iconSave_Edit = Icon(Icons.save); //chuyển icon thành save
          });
        } else {
          //nếu đang nhập thì kiểm tra
          if (_formKey1.currentState!.validate() &&
              _formKey2.currentState!.validate()) {
            setState(() {
              updateData(widget.uid).whenComplete((){
                _iconSave_Edit = Icon(Icons.edit);
                _disState = !_disState;
                FocusScope.of(context).unfocus(); //ẩn bàn phím
                GiaiThuat().name_databaseToFile();
                showToast('Đã cập nhật thông tin', null);
              });
            });
          }else{
            showToast('Lỗi nhập liệu\nVui lòng kiểm tra lại', null);
          }
        }
      },
      backgroundColor: COLOR_PRIMARY_1,
      child: _iconSave_Edit,
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
                // textFieldAcc(),
                textFieldEmail(),
                // textFieldPass(),
              ],
            ),
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
                    textFieldAddress()
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextFormField textFieldName() {
    return TextFormField(
      controller: _ten,
      enabled: _disState,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Họ tên nhân viên',
          labelStyle: labelText),
      style: info_user,
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

  TextFormField textFieldID() {
    return TextFormField(
      controller: _id,
      enabled: false,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
        ),
        labelText: 'ID',
        labelStyle: labelText,
      ),
      style: info_user,
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

  // TextFormField textFieldAcc() {
  //   return TextFormField(
  //     controller: _tk,
  //     enabled: _disState,
  //     decoration: InputDecoration(
  //         focusedBorder: UnderlineInputBorder(
  //           borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
  //         ),
  //         labelText: 'Tên đăng nhập',
  //         labelStyle: labelText),
  //     style: TextStyle(fontSize: FontSizeNormal),
  //     keyboardType: TextInputType.text,
  //     maxLength: 8,
  //     validator: (value) {
  //       if (value!.isNotEmpty)
  //         return null;
  //       else
  //         return 'Vui lòng nhập tên đăng nhập';
  //     },
  //   );
  // }

  TextFormField textFieldEmail() {
    return TextFormField(
      controller: _email,
      enabled: false,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Email',
          labelStyle: labelText),
      style: info_user,
      keyboardType: TextInputType.text,
      maxLength: 30,
      validator: (value) {
        if (value!.isNotEmpty)
          if(value.isValidEmail)
            return null;
          else
            return 'Email không hợp lệ';
        else
          return 'Vui lòng nhập email';
      },
    );
  }

  TextFormField textFieldPass() {
    return TextFormField(
      controller: _mk,
      enabled: _disState,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Mật khẩu',
          labelStyle: labelText),
      style: info_user,
      keyboardType: TextInputType.text,
      maxLength: 8,
      validator: (value) {
        if (value!.isNotEmpty)
          return null;
        else
          return 'Vui lòng nhập mật khẩu';
      },
    );
  }

  TextFormField textFieldDOB() {
    return TextFormField(
      controller: _ngaySinh,
      enabled: _disState,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
        ),
        labelText: 'Ngày sinh',
        labelStyle: labelText,
      ),
      style: info_user,
      keyboardType: TextInputType.number,
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

  TextFormField textFieldDOE() {
    return TextFormField(
      controller: _ngayVaoLam,
      enabled: _disState,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
          ),
          labelText: 'Ngày vào làm',
          labelStyle: labelText,
          suffixText: '*',
          suffixStyle: requiredText),
      style: info_user,
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value!.isValidDate)
          return null;
        else
          return 'Vui lòng nhập đúng định dạng';
      },
    );
  }

  TextFormField textFieldPhone() {
    return TextFormField(
      controller: _phone,
      enabled: _disState,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
        ),
        labelText: 'Số điện thoại',
        labelStyle: labelText,
      ),
      style: info_user,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isNotEmpty) {
          if (value.isValidPhone)
            return null;
          else
            return 'Vui lòng nhập đúng định dạng';
        } else
          _phone.text == null;
      },
    );
  }

  TextFormField textFieldAddress() {
    return TextFormField(
      controller: _diaChi,
      enabled: _disState,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: COLOR_PRIMARY_1, width: 2.0),
        ),
        labelText: 'Địa chỉ',
        labelStyle: labelText,
      ),
      style: info_user,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) _diaChi.text == null;
      },
    );
  }
}
