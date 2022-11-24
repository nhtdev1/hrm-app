import 'package:xeplich/list_contacts/components/listview_contacts.dart';
import 'package:xeplich/staff/bloc/staff_bloc.dart';
import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/header.dart';

class ListContacts extends StatelessWidget{
  final String uid_sender;

  const ListContacts({Key? key, required this.uid_sender}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: Text('Danh Sách Nhân Viên', style: titleAppBar),
        iconTheme: IconThemeData(color: COLOR_PRIMARY_1),
        centerTitle: true,
        backgroundColor: COLOR_PRIMARY,
      ),
      body: BlocProvider<StaffBloc>(
          create: (context) => StaffBloc(),
          child: Column(
            children: [
              Header(),
              ListViewContacts(uid_sender: uid_sender)
            ],
          )
      ),
    );
  }

}