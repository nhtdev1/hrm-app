import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xeplich/staff/add_member.dart';
import 'package:xeplich/staff/bloc/staff_bloc.dart';
import 'package:xeplich/staff/bloc/staff_event.dart';
import 'package:xeplich/staff/bloc/staff_state.dart';
import 'package:xeplich/tools/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
final double search_height = 40;

class Header extends StatelessWidget{
  // final int count;

  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    TextEditingController key_search = TextEditingController();
    final StaffBloc staffBloc = BlocProvider.of<StaffBloc>(context);

    // TODO: implement build
    return Container(
      height: size.height * 0.15 + search_height/2 + DefaultPadding/2,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: DefaultPadding/2),
            height: size.height * 0.15,
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
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
            ),
            child: Container(
              width: size.width,
              padding: EdgeInsets.only(bottom: DefaultPadding, left: DefaultPadding, right: DefaultPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Tổng số nhân viên: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                      BlocListener<StaffBloc, StaffState>(
                        bloc: staffBloc,
                        listener: (context, state){},
                        child: FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance.collection('users').get(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting)
                              return Text('...');
                            if(snapshot.hasData)
                              return Text((snapshot.data!.size - 1).toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red));
                            return Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red));
                          }),
                      ),
                    ],
                  ),
                  FloatingActionButton(
                    backgroundColor: COLOR_PRIMARY_1,
                    elevation: 10.0,
                    onPressed: (){
                      FirebaseFirestore.instance.collection('users').get().then((value){
                        int count = value.size;
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddMember(count: count)));
                      });
                    },
                    child: Icon(Icons.person_add, size: 28),
                    tooltip: 'Thêm nhân viên',
                  )
                ],
              ),
            ),
          ),
          Positioned(
              bottom: DefaultPadding/2,
              left: 0,
              child: Container(
                width: size.width,
                height: search_height,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: size.width - 8.0*2,
                    height: search_height,
                    padding: EdgeInsets.symmetric(horizontal: DefaultPadding/2),
                    decoration: BoxDecoration(
                      color: COLOR_PRIMARY_4,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow:  [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (keyword){
                        staffBloc.add(Increment());
                        staffBloc.add(UpdateData(keyword));
                        // context.read<StaffBloc>().add(Increment());
                      },
                      controller: key_search,
                      autocorrect: false,
                      cursorColor: COLOR_PRIMARY_1,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        icon: Icon(Icons.search, color: Colors.white),
                        hintText: 'Tìm kiếm',
                        hintStyle: TextStyle(fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: FontSizeNormal, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}