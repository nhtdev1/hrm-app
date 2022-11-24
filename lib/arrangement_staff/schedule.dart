import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/arrangement_admin/components/grid_day.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/giai_thuat_sap_lich.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../tools/function.dart';

class ArrangementStaff extends StatefulWidget {
  final String uid;

  const ArrangementStaff({Key? key, required this.uid}) : super(key: key);
  @override
  Schedule createState() => Schedule();
}

class Schedule extends State<ArrangementStaff> {
  final fireStore = FirebaseFirestore.instance;
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
  static const int _count = 21;
  final List<bool> list_schedule = [];
  final List<bool> list_check = List.generate(_count, (_) => false);
  bool _enableCheckbox = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: COLOR_PRIMARY,
        title: Text('Sắp Xếp', style: TextStyle(color: COLOR_PRIMARY_1)),
        iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Header(size, themeData),
          StreamBuilder(
              stream: fireStore.collection('users').doc(widget.uid).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  //điền dữ liệu vào lịch rảnh
                  var value = snapshot.data!.data() as Map<String, dynamic>;
                  list_schedule.clear();
                  for (int i = 0; i < 21; i++) {
                    if (value['lichRanh'][i] == '1')
                      list_schedule.add(true);
                    else
                      list_schedule.add(false);
                  }
                  return buildSchedule(size);
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

  Column buildSchedule(Size size) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: size.width / 4, height: size.height / 10),
            SizedBox(
              width: size.width - size.width / 4,
              height: size.height / 10,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
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
                            child: Center(child: Text(e.toString())),
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
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 4 / 2,
                crossAxisCount: 1,
                children: list_day.map((e) => GridviewDay(item: e)).toList(),
              ),
            ),
            SizedBox(
              width: (3 * size.width) / 4,
              height: (7 * size.width) / 8,
              child: buildGridSchedule(),
            ),
          ],
        ),
      ],
    );
  }

  GridView buildGridSchedule() {
    return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: 4 / 2,
        crossAxisCount: 3,
        children: List.generate(_count, (index) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(DefaultPadding / 5),
            decoration: BoxDecoration(
              color: COLOR_PRIMARY_1,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: COLOR_PRIMARY, width: 0.5),
            ),
            child: Checkbox(
              activeColor: Colors.white,
              checkColor: COLOR_PRIMARY_1,
              value: _enableCheckbox == false
                  ? list_schedule[index]
                  : list_check[index],
              onChanged: (value) {
                setState(() {
                  if (_enableCheckbox == true) list_check[index] = value!;
                });
              },
            ),
          );
        }).toList());
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
            'Lịch Rảnh Cá Nhân',
            style: themeData.textTheme.headline3,
          ),
          SizedBox(
              width: size.width - DefaultPadding * 2,
              child: Text(
                  'Lưu ý: Sau khi đã có LỊCH LÀM CHÍNH THỨC thì việc cập nhật lịch rảnh sẽ có tác dụng cho tuần sau',
                  style: themeData.textTheme.bodyText1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buttonEdit(size),
              addHorizontalSpace(DefaultPadding * 2),
              buttonSave(size),
            ],
          ),
          addVerticalSpace(DefaultPadding / 4)
        ],
      ),
    );
  }

  ElevatedButton buttonSave(Size size) {
    return ElevatedButton(
        onPressed: _enableCheckbox == false
            ? null
            : () {
                String s = '';
                for (int i = 0; i < 21; i++) {
                  if (list_check[i] == true)
                    s += '1';
                  else
                    s += '0';
                }
                setState(() {
                  _enableCheckbox = false;
                });

                showToast('Đã cập nhật lịch rảnh', null);
                fireStore
                    .collection('users')
                    .doc(widget.uid)
                    .update({'lichRanh': s}).then((value) {
                  GiaiThuat().lichRanh_databaseToFile(); //cập nhật lịch rảnh vào file sau khi thay đổi
                  GiaiThuat().lichRanh_old_databaseToFile();
                });
              },
        style: ButtonStyle(
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 5)),
            backgroundColor: _enableCheckbox == false
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
                      _enableCheckbox == false ? COLOR_PRIMARY : Colors.white,
                  size: 25,
                ),
                Text('Lưu và cập nhật',
                    style: TextStyle(
                        color: _enableCheckbox == false
                            ? COLOR_PRIMARY
                            : Colors.white))
              ],
            )));
  }

  ElevatedButton buttonEdit(Size size) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            _enableCheckbox = !_enableCheckbox;
            //copy list_schedule cho list_check để dễ theo dõi
            for (int i = 0; i < 21; i++) {
              list_check[i] = list_schedule[i];
            }
          });
        },
        style: ButtonStyle(
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 5)),
            backgroundColor: MaterialStateProperty.all<Color>(COLOR_CONTRAST),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))),
        child: SizedBox(
          width: size.width * 0.3,
          child: _enableCheckbox == false
              ? Column(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 25,
                    ),
                    Text('Chỉnh sửa', style: TextStyle(color: Colors.white))
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 25,
                    ),
                    Text('Hủy thay đổi', style: TextStyle(color: Colors.white))
                  ],
                ),
        ));
  }
}
