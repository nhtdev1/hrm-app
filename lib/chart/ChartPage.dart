import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/chart/BarChartNextWeek.dart';
import 'package:xeplich/chart/BarChartThisWeek.dart';
import 'package:xeplich/chart/BarChartToday.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:flutter/material.dart';

class Employee {
  final String uid;
  final String email;
  final String name;
  final int totalShiftToday;
  final int totalShiftThisWeek;
  final int totalShiftNextWeek;
  final List<int> todaySchedule;

  Employee(
    this.uid,
    this.email,
    this.name,
    this.totalShiftToday,
    this.totalShiftThisWeek,
    this.totalShiftNextWeek,
    this.todaySchedule,
  );

  static final mapSchedule = {
    0: [18, 19, 20],
    1: [0, 1, 2],
    2: [3, 4, 5],
    3: [6, 7, 8],
    4: [9, 10, 11],
    5: [12, 13, 14],
    6: [15, 16, 17],
  };

  static Employee fromJson(Map<String, dynamic> json) {
    String uid = json['uid'] ?? "";
    String email = json['email'] ?? "";
    String name = json['name'] ?? "";
    int totalShiftNextWeek = countHoursOfStaff(json["lichRanh"] ?? "");
    int totalShiftThisWeek = countHoursOfStaff(json["lichRanh_old"] ?? "");
    DateTime today = DateTime.now();
    List<int> todaySchedule = mapSchedule[
        today.weekday == 7 ? 0 : today.weekday]!; // 0 = Sun, 6 = Sat
    int totalShiftToday =
        countHoursOfStaffToday(json["lichRanh_old"] ?? "", todaySchedule);
    return Employee(
      uid,
      email,
      name,
      totalShiftToday,
      totalShiftThisWeek,
      totalShiftNextWeek,
      shiftsToday(json["lichRanh_old"] ?? "", todaySchedule),
    );
  }

  static int countHoursOfStaff(String schedule) {
    int total = 0;
    for (int i = 0; i < schedule.length; i++) {
      if (schedule[i] == '1') total++;
    }
    return total;
  }

  static int countHoursOfStaffToday(String schedule, List<int> todaySchedule) {
    int total = 0;
    if (schedule.isEmpty) return 0;
    todaySchedule.forEach((element) {
      if (schedule[element] == '1') total++;
    });
    return total;
  }

  static List<int> shiftsToday(String schedule, List<int> todaySchedule) {
    List<int> result = [];
    if (schedule.isEmpty) return [0, 0, 0];
    for (int i = 0; i < 3; i++) {
      result.add(schedule[todaySchedule[i]] == '1' ? 1 : 0);
    }
    return result;
  }
}

class ChartPage extends StatefulWidget {
  final String uid;

  const ChartPage({Key? key, required this.uid}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<Employee> employees = [];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: COLOR_PRIMARY,
        title: Text('Báo cáo thống kê', style: titleAppBar),
        iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              addVerticalSpace(DefaultPadding),
              Row(
                children: [
                  SizedBox(child: Icon(Icons.supervisor_account_rounded)),
                  const SizedBox(width: 8),
                  Text(
                    'Tổng số nhân viên: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  FutureBuilder<QuerySnapshot>(
                    future:
                        FirebaseFirestore.instance.collection('users').get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Text('...');
                      if (snapshot.hasData)
                        return Text(
                          (snapshot.data!.size - 1).toString(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red),
                        );
                      return Text(
                        '0',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      );
                    },
                  ),
                ],
              ),
              addVerticalSpace(DefaultPadding),
              Row(
                children: [
                  SizedBox(child: Icon(Icons.post_add)),
                  const SizedBox(width: 8),
                  Text(
                    'Tổng số bài viết: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('post').get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Text('...');
                      if (snapshot.hasData)
                        return Text(
                          (snapshot.data!.size - 1).toString(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red),
                        );
                      return Text(
                        '0',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      );
                    },
                  ),
                ],
              ),
              addVerticalSpace(DefaultPadding),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('users').get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Text('...');
                  if (snapshot.hasData) {
                    var values = snapshot.data!.docs;
                    values.forEach(
                      (element) {
                        var data = element.data() as Map<String, dynamic>;
                        if (data['no'] != '000') {
                          employees.add(Employee.fromJson(data));
                        }
                      },
                    );
                    return Column(
                      children: [
                        BarChartToday(employees),
                        addVerticalSpace(DefaultPadding),
                        BarChartThisWeek(employees),
                        addVerticalSpace(DefaultPadding),
                        BarChartNextWeek(employees),
                      ],
                    );
                  }
                  return Text('...');
                },
              ),
              addVerticalSpace(DefaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  int countHoursOfStaff(String schedule) {
    int total = 0;
    for (int i = 0; i < schedule.length; i++) {
      if (schedule[i] == '1') total++;
    }
    return total;
  }
}
