import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/file_storage.dart';
import 'package:xeplich/tools/giai_thuat_sap_lich.dart';
import 'package:xeplich/tools/push_notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tools/function.dart';
import 'components/grid_day.dart';

class Arrangement extends StatefulWidget {
  static const int _count = 21;

  @override
  _ArrangementState createState() => _ArrangementState();
}

class _ArrangementState extends State<Arrangement> {
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

  final list_item_lichDuKien = [];

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: COLOR_PRIMARY,
        title: Text('Lịch Làm', style: TextStyle(color: COLOR_PRIMARY_1)),
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
                  if (update != true) {
                    var values = snapshot.data!.data() as Map<dynamic, dynamic>;
                    String lichDuKien = values['lichDuKien'];
                    list_item_lichDuKien.clear();

                    var s1 = lichDuKien.split("_");
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
                            child: GridView.count(
                              childAspectRatio: 3 / 2,
                              crossAxisCount: 3,
                              children: list_session
                                  .map((e) => Card(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              COLOR_PRIMARY_2.withOpacity(0.4),
                                              Colors.white
                                            ],
                                          )),
                                          child:
                                              Center(child: Text(e.toString())),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )
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
                                  onTap: () async {
                                    List list = await list_nhanVienRanh(index);
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
        list_item_lichDuKien[index],
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

  Container Header(Size size, ThemeData themeData) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      height: size.height * 0.2,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lịch Dự Kiến',
            style: themeData.textTheme.headline3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: update == true
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
                      backgroundColor: update == true
                          ? MaterialStateProperty.all<Color>(COLOR_CONTRAST_2)
                          : MaterialStateProperty.all<Color>(COLOR_CONTRAST),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                  child: SizedBox(
                      width: size.width * 0.3,
                      child: Column(
                        children: [
                          Icon(
                            Icons.edit,
                            color:
                                update != true ? Colors.white : COLOR_PRIMARY,
                            size: 25,
                          ),
                          Text('Xếp lịch',
                              style: TextStyle(
                                  color: update != true
                                      ? Colors.white
                                      : COLOR_PRIMARY))
                        ],
                      ))),
              addHorizontalSpace(DefaultPadding * 2),
              ElevatedButton(
                  onPressed: update != true
                      ? null
                      : () {
                          setState(() {
                            //lưu lịch
                            String lichDuKien = '';
                            for (int i = 0; i < 21; i++) {
                              lichDuKien += list_item_lichDuKien[i] + '_';
                            }

                            fireStore
                                .collection('lich')
                                .doc('lich')
                                .update({'lichDuKien': lichDuKien});
                            update = false;
                            showToast('Đã lưu lịch dự kiến', null);
                          });
                          fireStore.collection('lich').doc('lich').snapshots().listen((event) {
                            PushNotificationService().addNotification('Lịch Làm Hằng Tuần', 'Quản lý đã cập nhật lịch làm cho tuần mới. Nhấn vào xem');
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
                      width: size.width * 0.3,
                      child: Column(
                        children: [
                          Icon(
                            Icons.save,
                            color:
                                update == true ? Colors.white : COLOR_PRIMARY,
                            size: 25,
                          ),
                          Text('Lưu và cập nhật',
                              style: TextStyle(
                                  color: update == true
                                      ? Colors.white
                                      : COLOR_PRIMARY))
                        ],
                      ))),
            ],
          ),
          addVerticalSpace(DefaultPadding / 4)
        ],
      ),
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
                  list_item_lichDuKien[gridIndex] = list[index];
                  Navigator.pop(context);
                });
              });
        },
      ),
    );
  }
}
