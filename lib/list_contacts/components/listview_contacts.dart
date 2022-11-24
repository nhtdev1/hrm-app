import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/chat/chat_content.dart';
import 'package:xeplich/staff/bloc/staff_bloc.dart';
import 'package:xeplich/staff/bloc/staff_state.dart';
import 'package:xeplich/tools/const.dart';
import 'package:xeplich/tools/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListViewContacts extends StatelessWidget{
  final String uid_sender;

  ListViewContacts({Key? key, required this.uid_sender}) : super(key: key);

  List list_staff = [];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);

    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state){
        if(state is Loaded){
          return StreamBuilder<QuerySnapshot>(
              stream: state.snapshot,
              builder: (context, snapshot){
                if(snapshot.hasData) {
                  list_staff.clear();
                  // FileStorage().cleanFile('name');
                  var values = snapshot.data!.docs;
                  values.forEach((element) {
                    var data = element.data() as Map<String, dynamic>;
                    if (data['uid'] != uid_sender) {
                      list_staff.add(data);
                      // String s = data['name'];
                      // FileStorage().writeFile(s.substring(s.lastIndexOf(" ") + 1),
                      //     'name'); //lưu tên các nhân viên
                    }
                  });
                  return Expanded(
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: list_staff.length,
                        itemBuilder: (BuildContext context, int index) {
                          return cardMemberItem(
                              context, index, size, themeData);
                        }),
                  );
                } return CircularProgressIndicator();
              }
          );

        } return CircularProgressIndicator();
      },
    );
  }

  InkWell cardMemberItem(
      BuildContext context, int index, Size size, ThemeData themeData) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatContent(
                  info_data: list_staff[index], sender_uid: uid_sender)),
        );
      },
      child: Container(
        height: size.width / 5,
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(DefaultPadding - 8.0),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // CircleAvatar(backgroundImage: AssetImage('assets/default_avatar.jpg'), radius: 30.0),
                  cacheImgAvt(list_staff[index]['email'], 30),
                  addHorizontalSpace(DefaultPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        list_staff[index]['name'],
                        style: themeData.textTheme.headline4,
                      ),
                      addVerticalSpace(DefaultPadding / 4),
                      Text(list_staff[index]['no'])
                    ],
                  ),
                ],
              ),
            ),
            addHorizontalSpace(DefaultPadding * 4),
          ],
        ),
      ),
    );
  }
}