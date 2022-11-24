import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/schedule/components/grid_content.dart';
import 'package:xeplich/schedule/components/grid_day.dart';
import 'package:xeplich/schedule/schedule_staff/schedule_staff.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/file_storage.dart';
import 'package:xeplich/tools/function.dart';
import 'package:xeplich/tools/giai_thuat_sap_lich.dart';
import 'package:xeplich/tools/push_notification_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';

import 'schedule_admin/schedule_admin.dart';
// export 'package:xeplich/arrangement_admin/schedule.dart';

class ViewSchedule extends StatefulWidget {
  static const int _count = 21;
  final String? name;
  final bool isAdmin;
  final String? uid_staff;

  const ViewSchedule({Key? key, this.name, required this.isAdmin, this.uid_staff}) : super(key: key);

  @override
  _ViewScheduleState createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<ViewSchedule> {
  final fb = FirebaseDatabase.instance;
  final fireStore = FirebaseFirestore.instance;
  bool update = false;

  final List<String> list_session = ['Sáng', 'Trưa', 'Chiều'];

  final List<String> list_day = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhựt',
  ];

  final List<String> list_item_lichChinhThuc = [];

  final List<String> list_item_lichDuKien = [];
  bool? isNow;
  DateFormat df = DateFormat("HH:mm");

  String TraVeTuan(int index){ //index = 0 : tuần này, 1 : tuần sau
    String firstDay, lastDay;
    DateFormat dateFormat = DateFormat("dd/MM/yy");
    DateTime today = DateTime.now();

    int Thu = today.weekday; // 0 = Sun, 6 = Sat

    if(index == 1){
      firstDay = dateFormat.format(today.add(Duration(days: -(Thu - 1) + 7)));
      lastDay = dateFormat.format(today.add(Duration(days: (7 - Thu) +7)));
    }
    else{
      firstDay = dateFormat.format(today.add(Duration(days: -(Thu - 1))));
      lastDay = dateFormat.format(today.add(Duration(days: (7 - Thu))));
    }

    return firstDay + ' - ' + lastDay;
  }

  Future<List> list_nhanVienRanh_old(int index) async {
    List<int> list_order = [];
    List<String> list_name = [];

    var file_lichRanh = await FileStorage().readFile('lichRanh_old');
    List lichRanh = file_lichRanh.split("\n"); //cắt file

    for (int i = 0; i < lichRanh.length - 1; i++) {
      if (lichRanh[i][index] == '1') list_order.add(i);
    }
    var file_name = await FileStorage().readFile('name');
    List name = file_name.split("\n");

    list_order.forEach((element) async {
      list_name.add(name[element]);
    });
    return await list_name;
  }

  Future<List> list_nhanVienRanh(int index) async {
    List<int> list_order = [];
    List<String> list_name = [];

    var file_lichRanh = await FileStorage().readFile('lichRanh');
    List lichRanh = file_lichRanh.split("\n"); //cắt file

    for (int i = 0; i < lichRanh.length - 1; i++) {
      if (lichRanh[i][index] == '1') list_order.add(i);
    }
    var file_name = await FileStorage().readFile('name');
    List name = file_name.split("\n");

    list_order.forEach((element) async {
      list_name.add(name[element]);
    });
    return await list_name;
  }

  Future<List<Session>> listSession(int num) async{//lichChinhThuc = 0, lichDuKien = 1
    List<Session> list = [];
    String lich = num == 0 ? 'time_lichChinhThuc' : 'time_lichDuKien';
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('lich').doc(lich).get();
    snapshot.data()!.forEach((key, value) {
       Session s = Session(value[0], value[1]);
       list.add(s);
    });
    return await list;
  }

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance;
    Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: COLOR_PRIMARY,
        title: Text('Lịch Làm', style: titleAppBar),
        iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Header(size, themeData),
          StreamBuilder(
              stream: fireStore.collection('lich').doc('lich').snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  //điền dữ liệu vào lịch
                  if(update != true) {
                    var values = snapshot.data!.data() as Map<String, dynamic>;
                    String lichChinhThuc = values['lichChinhThuc'];
                    String lichDuKien = values['lichDuKien'];

                    list_item_lichChinhThuc.clear();
                    list_item_lichDuKien.clear();

                    var s1 = lichChinhThuc.split("_");
                    for (String s2 in s1) {
                      if (s2 != '') //loại bỏ phần tử rỗng cuối cùng trong chuỗi
                        list_item_lichChinhThuc.add(s2);
                    }

                    s1 = lichDuKien.split("_");
                    for (String s2 in s1) {
                      if (s2 != '') list_item_lichDuKien.add(s2);
                    }
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: size.width / 4, height: size.height / 10),
                          SizedBox(
                            width: size.width - size.width / 4,
                            height: size.height / 10,
                            child: FutureBuilder<List<Session>>(
                              future: listSession(isNow != false ? 0 : 1),
                                builder: (context, AsyncSnapshot<List<Session>> snapshot){
                                  if(snapshot.hasData){
                                    return GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 3 / 2,
                                        ),
                                        itemCount: 3,
                                        itemBuilder: (context, index) => _buildItemSessionCard(context ,size, snapshot.data!.elementAt(index), index),
                                    );
                                  } return GridView.count(
                                    childAspectRatio: 3 / 2,
                                    crossAxisCount: 3,
                                    children: list_session
                                        .map((e) => _buildItemSessionCard(context ,size, e, 0)).toList(),
                                  );
                                }),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: size.width / 4,
                            height: (7 * size.width) / 8,
                            child: GridView.count(
                              childAspectRatio: 4 / 2,
                              crossAxisCount: 1,
                              children: list_day
                                  .map((e) => GridviewDay(item: e))
                                  .toList(),
                            ),
                          ),
                          SizedBox(
                            width: (3 * size.width) / 4,
                            height: (7 * size.width) / 8,
                            child: GridView.builder(
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 4 / 2,
                              ),
                              itemCount: list_item_lichDuKien.length,
                              itemBuilder: (context, index) {
                                return InkResponse(
                                  onTap: update == false ? null : () async {
                                    List list;
                                    isNow != false
                                      ? list = await list_nhanVienRanh_old(index)
                                      : list = await list_nhanVienRanh(index);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return buildAlertDialog(
                                              context, list, index);
                                        });
                                  },
                                  child: buildGridItemContent(index),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: CircularProgressIndicator(
                    color: COLOR_PRIMARY_1,
                  ),
                );
              }),
        ],
      ),
    );
  }

  Container Header(Size size, ThemeData themeData) {
    return Container(
      padding: EdgeInsets.only(left: DefaultPadding, right: DefaultPadding),
      margin: EdgeInsets.only(bottom: 10),
          height: widget.isAdmin == true ? size.height * 0.25 :  size.height * 0.15,
          decoration: BoxDecoration(
            boxShadow:  [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            color: COLOR_PRIMARY,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isNow == false ? Text('Tuần Kế Tiếp', style: titleText,) : Text('Tuần Hiện Tại', style: titleText,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isNow = true;
                          update = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        // padding: EdgeInsets.all(5),
                        primary: isNow != false ? Color.fromRGBO(255, 150, 7, 100) : COLOR_CONTRAST, // <-- Button color
                        onPrimary: isNow != false ? Colors.white54 : Colors.white, // <-- Splash color
                      ),
                      child: Icon(
                            Icons.navigate_before,
                            size: 30.0,
                            )
                  ),
                  SizedBox(
                    // width: size.width * 0.6,
                    height: 50.0,
                    child: Center(
                      child: isNow != false ? Text(TraVeTuan(0), style: TextStyle(color: COLOR_PRIMARY_1, fontSize: 20, fontWeight: FontWeight.w900))
                      : Text(TraVeTuan(1), style: TextStyle(color: COLOR_PRIMARY_1, fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isNow = false;
                          update = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        // padding: EdgeInsets.all(5),
                        primary: isNow != false ? COLOR_CONTRAST : Color.fromRGBO(255, 150, 7, 100), // <-- Button color
                        onPrimary: isNow != false ? Colors.white : Colors.white54, // <-- Splash color
                      ),
                      child: Icon(
                        Icons.navigate_next,
                        size: 30.0,
                      )
                  ),
                ],
              ),
              if(widget.isAdmin == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: isNow != false
                          ? null
                          : () async {
                        //đếm nhân viên trong file 'name'
                        var name = await FileStorage().readFile('name');
                        List count = name.split("\n"); //cắt file

                        list_item_lichDuKien.clear();
                        list_item_lichDuKien.addAll(
                            await GiaiThuat().sapLich(count.length - 1));

                        setState(() {
                          update = true;
                        });
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 5)),
                          backgroundColor: isNow != false
                              ? MaterialStateProperty.all<Color>(COLOR_CONTRAST_2)
                              : MaterialStateProperty.all<Color>(COLOR_CONTRAST),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                      child: SizedBox(
                          width: size.width * 0.2,
                          child: Column(
                            children: [
                              Icon(
                                Icons.edit,
                                color: isNow != false ? COLOR_PRIMARY : Colors.white,
                                size: 25,
                              ),
                              Text('Xếp lịch',
                                  style: TextStyle(
                                      color: isNow != false ? COLOR_PRIMARY : Colors.white,))
                            ],
                          ))),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          update = !update;
                        });
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 5)),
                          backgroundColor: MaterialStateProperty.all<Color>(COLOR_CONTRAST),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                      child: SizedBox(
                          width: size.width * 0.2,
                          child: Column(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 25,
                              ),
                              Text(update != true ? 'Chỉnh sửa' : 'Huỷ',
                                  style: TextStyle(
                                      color: Colors.white))
                            ],
                          ))),
                  ElevatedButton(
                      onPressed: update != true
                          ? null
                          : () {
                        setState(() {
                          //lưu lịch
                          String lich = '';
                          for (int i = 0; i < 21; i++) {
                            isNow != false
                              ? lich += list_item_lichChinhThuc[i] + '_'
                              : lich += list_item_lichDuKien[i] + '_';
                          }

                          isNow != false
                            ? fireStore.collection('lich').doc('lich').update({'lichChinhThuc' : lich})
                            : fireStore.collection('lich').doc('lich').update({'lichDuKien' : lich});
                          update = false;
                          showToast('Đã lưu các cập nhật', null);
                        });
                        fireStore.collection('lich').doc('lich').snapshots().listen((event) {
                          isNow != false
                            ? PushNotificationService().addNotification('Lịch Làm Hằng Tuần', 'Lịch làm tuần hiện tại đã có sự thay đổi. Nhấn vào xem')
                            : PushNotificationService().addNotification('Lịch Làm Hằng Tuần', 'Quản lý đã cập nhật lịch làm cho tuần mới. Nhấn vào xem');
                        });
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 5)),
                          backgroundColor: update != true
                              ? MaterialStateProperty.all<Color>(COLOR_CONTRAST_2)
                              : MaterialStateProperty.all<Color>(COLOR_CONTRAST),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                      child: SizedBox(
                          width: size.width * 0.2,
                          child: Column(
                            children: [
                              Icon(
                                Icons.save,
                                color:
                                update == true ? Colors.white : COLOR_PRIMARY,
                                size: 25,
                              ),
                              Text('Lưu',
                                  style: TextStyle(
                                      color: update == true
                                          ? Colors.white
                                          : COLOR_PRIMARY))
                            ],
                          )
                      )
                  ),
                ],
              ),
              addVerticalSpace(10)
            ],
          ),
        );
  }

  Container buildGridItemContent(int index) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(DefaultPadding / 5),
      decoration: BoxDecoration(
        color: COLOR_PRIMARY_1,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        border: Border.all(color: COLOR_PRIMARY, width: 0.5),
      ),
      child: Text(
        isNow != false
            ? list_item_lichChinhThuc[index]
            : list_item_lichDuKien[index],
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  AlertDialog buildAlertDialog(BuildContext context, List<dynamic> list, int index) {
    return AlertDialog(
      actionsPadding: EdgeInsets.only(bottom: 15),
      titlePadding: EdgeInsets.only(top: 30, bottom: 10),
      title: Center(
          child: Text(
            'Lựa chọn nhân viên muốn đổi',
            style: titleText,
          )),
      content: dialogContainer(context, list, index),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop("No");
            },
            child: Text('Hủy'),
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 5)),
                backgroundColor:
                MaterialStateProperty.all<Color>(COLOR_PRIMARY_1),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
          ),
        )
      ],
    );
  }

  Widget dialogContainer(BuildContext context, List list, int gridIndex) {
    Size size = MediaQuery.of(context).size;
    String? _group = '';
    return Container(
      height: size.height * 0.4, // Change as per your requirement
      width: size.width * 0.8, // Change as per your requirement
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        // shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return RadioListTile<String>(
              title: Text(
                list[index].toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              value: list[index],
              groupValue: _group,
              onChanged: (value) {
                setState(() {
                  _group = value;
                  isNow != false
                      ? list_item_lichChinhThuc[gridIndex] = list[index]
                      : list_item_lichDuKien[gridIndex] = list[index];
                  print(list_item_lichChinhThuc);
                  Navigator.pop(context);
                });
              });
        },
      ),
    );
  }

  Container _buildBottomSheet(Size size, int session_num){
    String _timeIn = '', _timeOut = '';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DefaultPadding*1.5),
      height: size.height * 0.3,
      decoration: BoxDecoration(
          color: COLOR_PRIMARY_3,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
      child: Stack(
          children:[
            Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TimePickerSpinner(
                      normalTextStyle: TextStyle(
                          fontSize: 24,
                          color: COLOR_CONTRAST_1
                      ),
                      highlightedTextStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: COLOR_PRIMARY_1
                      ),
                      spacing: 25,
                      itemHeight: 50,
                      isForce2Digits: true,
                      minutesInterval: 15,
                      onTimeChange: (time) {
                        _timeIn = df.format(time).toString();
                      },
                    ),
                    Center(child: Text('-', style: titleText,)),
                    TimePickerSpinner(
                      normalTextStyle: TextStyle(
                          fontSize: 24,
                          color: COLOR_CONTRAST_1
                      ),
                      highlightedTextStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: COLOR_PRIMARY_1
                      ),
                      spacing: 25,
                      itemHeight: 50,
                      isForce2Digits: true,
                      minutesInterval: 15,
                      onTimeChange: (time) {
                        _timeOut = df.format(time).toString();
                      },
                    ),
                  ],
                )
            ),
            Positioned(
                right: 0,
                top: 10,
                child: InkResponse(
                  child: Text('OK', style: TextStyle(color: Colors.red)),
                  onTap: (){
                    print(_timeIn + ' - ' + _timeOut);
                    FirebaseFirestore.instance.collection('lich').doc(isNow != false ? 'time_lichChinhThuc' : 'time_lichDuKien').update({
                      '$session_num' : [_timeIn, _timeOut]
                    });
                    setState(() {

                    });
                    Navigator.pop(context);
                  },
                )
            )
          ]
      ),
    );
  }

  Widget _buildItemSessionCard(BuildContext context, Size size, dynamic element, int session_num){
    return Card(
      child: InkResponse(
        onTap: (){
          widget.isAdmin != true ? null :
          showBottomSheet(context: context,
              builder: (context){
                return _buildBottomSheet(size, session_num);
              });
        },
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // COLOR_CONTRAST_1,
                  COLOR_PRIMARY_2.withOpacity(0.4),
                  Colors.white
                ],
              )),
          child:
          Center(child: (element is Session) ? Text(element.timeIn + ' - ' + element.timeOut) : Text(element.toString())),
        ),
      ),
    );
  }
}

class Session {
  final String timeIn;
  final String timeOut;

  Session(this.timeIn, this.timeOut);
}
